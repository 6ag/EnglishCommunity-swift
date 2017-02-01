//
//  AppDelegate.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/1.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SwiftyJSON
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate {
    
    var window: UIWindow?
    var webServer = MongooseDaemon()
    var hostReach: Reachability?
    var networkState = 0
    
    // 给注册推送时用 - 因为注册推送想在主界面加载出来才询问是否授权
    var launchOptions: [AnyHashable: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupRootViewController() // 配置控制器
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupShareSDK()           // 配置shareSDK
        setupReachability()       // 配置网络检测
        
        return true
    }
    
    /**
     配置web服务器
     */
    func setupWebServer() {
        webServer.start("8080")
    }
    
    /**
     配置默认播放节点
     */
    fileprivate func setupPlayNode() {
        
        JFNetworkTools.shareNetworkTool.getPlayNode { (success, result, error) in
            guard let result = result else {
                return
            }
            
            // 更新全局节点
            let node = result["result"]["node"].stringValue
            if node == "app" {
                PLAY_NODE = "app"
            } else {
                PLAY_NODE = "web"
            }
            
        }
    }
    
    /**
     配置网络检测
     */
    fileprivate func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        hostReach = Reachability.forInternetConnection()
        hostReach?.startNotifier()
    }
    
    /**
     监听网络状态改变
     */
    @objc func reachabilityChanged(_ notification: Notification) {
        
        guard let curReach = notification.object as? Reachability else {
            return
        }
        
        switch curReach.currentReachabilityStatus() {
        case NetworkStatus.NotReachable:
            print("无网络")
        case NetworkStatus.ReachableViaWiFi:
            networkState = 1
            print("WiFi")
        case NetworkStatus.ReachableViaWWAN:
            networkState = 2
            print("WAN")
        }
        
    }
    
    /**
     配置全局数据
     */
    fileprivate func setupGlobalData() {
        // 验证缓存的账号是否有效
        JFAccountModel.checkToken()
    }
    
    /**
     配置shareSDK
     */
    fileprivate func setupShareSDK() {
        
        ShareSDK.registerApp(SHARESDK_APP_KEY, activePlatforms:[
            SSDKPlatformType.typeSinaWeibo.rawValue,
            SSDKPlatformType.typeQQ.rawValue,
            SSDKPlatformType.typeWechat.rawValue],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform {
                                case SSDKPlatformType.typeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.typeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                case SSDKPlatformType.typeSinaWeibo:
                                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                                default:
                                    break
                                }
                                
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
            switch platform {
            case SSDKPlatformType.typeWechat:
                // 微信
                appInfo?.ssdkSetupWeChat(byAppId: WX_APP_ID, appSecret: WX_APP_SECRET)
                
            case SSDKPlatformType.typeQQ:
                // QQ
                appInfo?.ssdkSetupQQ(byAppId: QQ_APP_ID,
                                     appKey : QQ_APP_KEY,
                                     authType : SSDKAuthTypeBoth)
            case SSDKPlatformType.typeSinaWeibo:
                appInfo?.ssdkSetupSinaWeibo(byAppKey: WB_APP_KEY,
                                            appSecret: WB_APP_SECRET,
                                            redirectUri: WB_REDIRECT_URL,
                                            authType: SSDKAuthTypeBoth)
            default:
                break
            }
            
        }
    }
    
    /**
     全局样式
     */
    fileprivate func setupGlobalStyle() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        JFProgressHUD.setupHUD() // 配置HUD
    }
    
    /**
     添加根控制器
     */
    fileprivate func setupRootViewController() {
        
        window = UIWindow(frame: SCREEN_BOUNDS)
        window?.backgroundColor = COLOR_NAV_BG
        window?.rootViewController = JFTabBarController()
        window?.makeKeyAndVisible()
        
        // 测试FPS
//        window?.addSubview(JFFPSLabel(frame: CGRect(x: SCREEN_WIDTH - 60, y: 26, width: 50, height: 30)))
    }
    
    /**
     配置极光推送
     */
    func setupJPush() {
        
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        } else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        JPUSHService.setup(withOption: launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
        JPUSHService.crashLogON()
        
        // 延迟发送通知（app被杀死进程后收到通知，然后通过点击通知打开app在这个方法中发送通知）
        perform(#selector(sendNotification(_:)), with: launchOptions, afterDelay: 1.5)
    }
    
    /**
     发送通知
     */
    @objc fileprivate func sendNotification(_ launchOptions: [AnyHashable: Any]?) {
        if let options = launchOptions {
            let userInfo = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: JFDidReceiveRemoteNotificationOfJPush), object: nil, userInfo: userInfo)
        }
    }
    
    /**
     注册 DeviceToken
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /**
     注册远程通知失败
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    /**
     将要显示
     */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
            }
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))
    }
    
    /**
     已经收到消息
     */
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger {
            if trigger.isKind(of: UNPushNotificationTrigger.classForCoder()) {
                JPUSHService.handleRemoteNotification(userInfo)
                // 处理远程通知
                remoteNotificationHandler(userInfo: userInfo)
            }
        }
        completionHandler()
    }
    
    /**
     iOS7后接收到远程通知
     */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        // 处理远程通知
        remoteNotificationHandler(userInfo: userInfo)
    }
    
    /// 处理远程通知
    ///
    /// - Parameter userInfo: 通知数据
    private func remoteNotificationHandler(userInfo: [AnyHashable : Any]) {
        
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            NotificationCenter.default.post(name: Notification.Name(rawValue: JFDidReceiveRemoteNotificationOfJPush), object: nil, userInfo: userInfo)
        } else if UIApplication.shared.applicationState == .active {
            let message = (userInfo as [AnyHashable : AnyObject])["aps"]!["alert"] as! String
            let alertC = UIAlertController(title: "收到新的消息", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let confrimAction = UIAlertAction(title: "查看", style: UIAlertActionStyle.destructive, handler: { (action) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: JFDidReceiveRemoteNotificationOfJPush), object: nil, userInfo: userInfo)
            })
            let cancelAction = UIAlertAction(title: "忽略", style: UIAlertActionStyle.default, handler: nil)
            alertC.addAction(confrimAction)
            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setupPlayNode()           // 配置默认播放节点
        setupWebServer()          // 配置web服务器
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

