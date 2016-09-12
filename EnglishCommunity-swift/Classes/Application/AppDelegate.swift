//
//  AppDelegate.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/1.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SwipeBack
import SwiftyJSON
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var webServer = MongooseDaemon()
    var hostReach: Reachability?
    var networkState = 0
    
    // 给注册推送时用 - 因为注册推送想在主界面加载出来才询问是否授权
    var launchOptions: [NSObject: AnyObject]?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        setupRootViewController() // 配置控制器
        setupGlobalStyle()        // 配置全局样式
        setupGlobalData()         // 配置全局数据
        setupShareSDK()           // 配置shareSDK
        setupReachability()       // 配置网络检测
        self.launchOptions = launchOptions
        
        return true
    }
    
    /**
     配置web服务器
     */
    func setupWebServer() {
        webServer.startMongooseDaemon("8080")
    }
    
    /**
     配置默认播放节点
     */
    private func setupPlayNode() {
        
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
    private func setupReachability() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        hostReach = Reachability.reachabilityForInternetConnection()
        hostReach?.startNotifier()
    }
    
    /**
     监听网络状态改变
     */
    @objc func reachabilityChanged(notification: NSNotification) {
        
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
    private func setupGlobalData() {
        // 验证缓存的账号是否有效
        JFAccountModel.checkToken()
    }
    
    /**
     配置shareSDK
     */
    private func setupShareSDK() {
        
        ShareSDK.registerApp(SHARESDK_APP_KEY,
                             activePlatforms: [
                                SSDKPlatformType.TypeSinaWeibo.rawValue,
                                SSDKPlatformType.TypeQQ.rawValue,
                                SSDKPlatformType.TypeWechat.rawValue],
                             onImport: {(platform : SSDKPlatformType) -> Void in
                                switch platform {
                                case SSDKPlatformType.TypeWechat:
                                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                case SSDKPlatformType.TypeQQ:
                                    ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                default:
                                    break
                                }},
                             onConfiguration: {(platform : SSDKPlatformType,appInfo : NSMutableDictionary!) -> Void in
                                switch platform {
                                case SSDKPlatformType.TypeSinaWeibo:
                                    appInfo.SSDKSetupSinaWeiboByAppKey(WB_APP_KEY, appSecret : WB_APP_SECRET, redirectUri : WB_REDIRECT_URL, authType : SSDKAuthTypeBoth)
                                case SSDKPlatformType.TypeWechat:
                                    appInfo.SSDKSetupWeChatByAppId(WX_APP_ID, appSecret: WX_APP_SECRET)
                                case SSDKPlatformType.TypeQQ:
                                    appInfo.SSDKSetupQQByAppId(QQ_APP_ID, appKey: QQ_APP_KEY, authType: SSDKAuthTypeBoth)
                                default:
                                    break
                                }})
    }
    
    /**
     全局样式
     */
    private func setupGlobalStyle() {
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        JFProgressHUD.setupHUD() // 配置HUD
    }
    
    /**
     添加根控制器
     */
    private func setupRootViewController() {
        
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
        JPUSHService.registerForRemoteNotificationTypes(UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Sound.rawValue, categories: nil)
        JPUSHService.setupWithOption(launchOptions, appKey: JPUSH_APP_KEY, channel: JPUSH_CHANNEL, apsForProduction: JPUSH_IS_PRODUCTION)
        JPUSHService.crashLogON()
        JPUSHService.setLogOFF()
        
        // 延迟发送通知（app被杀死进程后收到通知，然后通过点击通知打开app在这个方法中发送通知）
        performSelector(#selector(sendNotification(_:)), withObject: launchOptions, afterDelay: 1)
    }
    
    /**
     发送通知
     */
    @objc private func sendNotification(launchOptions: [NSObject: AnyObject]?) {
        if let options = launchOptions {
            let userInfo = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
            NSNotificationCenter.defaultCenter().postNotificationName(JFDidReceiveRemoteNotificationOfJPush, object: nil, userInfo: userInfo)
        }
    }
    
    /**
     传递deviceToken注册远程通知
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    /**
     注册远程通知失败
     */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    /**
     iOS7后接收到远程通知
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
        
        if application.applicationState == .Background || application.applicationState == .Inactive {
            NSNotificationCenter.defaultCenter().postNotificationName(JFDidReceiveRemoteNotificationOfJPush, object: nil, userInfo: userInfo)
        } else if application.applicationState == .Active {
            let message = userInfo["aps"]!["alert"] as! String
            let alertC = UIAlertController(title: "收到新的消息", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let confrimAction = UIAlertAction(title: "查看", style: UIAlertActionStyle.Destructive, handler: { (action) in
                NSNotificationCenter.defaultCenter().postNotificationName(JFDidReceiveRemoteNotificationOfJPush, object: nil, userInfo: userInfo)
            })
            let cancelAction = UIAlertAction(title: "忽略", style: UIAlertActionStyle.Default, handler: { (action) in
                
            })
            alertC.addAction(confrimAction)
            alertC.addAction(cancelAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertC, animated: true, completion: nil)
        }
    }
    
    /**
     接收到本地通知
     */
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        JPUSHService.showLocalNotificationAtFront(notification, identifierKey: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        setupPlayNode()           // 配置默认播放节点
        setupWebServer()          // 配置web服务器
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
}

