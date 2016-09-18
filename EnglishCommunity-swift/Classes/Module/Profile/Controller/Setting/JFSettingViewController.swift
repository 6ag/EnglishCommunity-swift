//
//  JFSettingViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/20.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage
import SDWebImage
import StoreKit

// MARK: - SKProductsRequestDelegate, SKPaymentTransactionObserver
extension JFSettingViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - 添加移除监听
    /**
     添加监听
     */
    func addTransactionObserver() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    /**
     移除监听
     */
    func removeTransactionObserver() {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    // MARK: - 发起内购请求
    /**
     向苹果服务器请求可销售商品,填写itunes connect中添加的商品id
     */
    func requestProducts(productID: String) {
        
        addTransactionObserver()
        if SKPaymentQueue.canMakePayments() {
            JFProgressHUD.showWithStatus("发起内购")
            let request = SKProductsRequest(productIdentifiers: NSSet(array: [productID]) as! Set<String>)
            request.delegate = self;
            request.start()
        } else {
            removeTransactionObserver()
        }
        
    }
    
    /**
     恢复购买
     */
    func restoreProduct() {
        
        addTransactionObserver()
        if SKPaymentQueue.canMakePayments() {
            JFProgressHUD.showWithStatus("正在恢复内购项目")
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        } else {
            removeTransactionObserver()
        }
        
    }
    
    /**
     请求产品信息回调
     */
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        for product in response.products  {
            if product.productIdentifier == productID {
                let payment = SKPayment(product: product)
                SKPaymentQueue.defaultQueue().addPayment(payment)
                return
            }
        }
    }
    
    // MARK: - 付款队列
    /**
     更新交易
     */
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        JFProgressHUD.dismiss()
        for transaction in transactions {
            
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                
                // 购买完成
                verifyPruchase()
                buyDislodgeAD()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                
                // 购买失败
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Restored:
                
                // 恢复购买
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Purchasing:
                
                // 正在处理
                print("商品购买正在处理")
                
            case SKPaymentTransactionState.Deferred:
                
                // 购买推迟
                print("商品购买推迟")
                
            }
            
        }
        
    }
    
    /**
     移除了交易
     */
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("移除了交易")
    }
    
    /**
     加载什么鬼
     */
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("下载什么鬼")
    }
    
    // MARK: - 恢复购买
    /**
     商品恢复购买失败
     */
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        print("商品恢复购买失败")
        JFProgressHUD.showInfoWithStatus("恢复失败")
    }
    
    /**
     商品恢复购买完成
     */
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        buyDislodgeAD()
    }
    
    // MARK: - 验证交易凭据
    /**
     验证交易凭据，获取到苹果返回的交易凭据
     */
    func verifyPruchase() {
        
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
        
        // 从沙盒中获取到购买凭据
        let receiptData = NSData(contentsOfURL: receiptURL!)
        
        // 发送网络POST请求，对购买凭据进行验证
        let url = NSURL(string: APPSTORE_VERIFY)
        
        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        
        // 请求体
        let encodeStr = receiptData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr! + "\"}")
        request.HTTPBody = payload.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let semaphore = dispatch_semaphore_create(0)
        
        let dataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if error != nil {
                print(error?.code)
                print(error?.description)
            } else {
                let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(str)
                // 官方验证结果为空
                if data == nil {
                    // 验证失败
                    print("验证失败")
                    return
                }
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if jsonResult.count != 0 {
                        // 比对字典中以下信息基本上可以保证数据安全
                        // bundle_id&application_version&product_id&transaction_id
                        // 凭证验证成功
                        let receipt = jsonResult["receipt"] as! NSDictionary
                        print(receipt["bundle_id"])
                    }
                } catch {
                    print("验证凭证出错")
                }
            }
            
            dispatch_semaphore_signal(semaphore)
        }) as NSURLSessionTask
        
        //使用resume方法启动任务
        dataTask.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}

class JFSettingViewController: JFBaseTableViewController {
    
    /// 商品ID
    let productID = "dislodge_ad"
    
    /// 正式环境验证
    private let APPSTORE_VERIFY  = "https://buy.itunes.apple.com/verifyReceipt"
    
    /// 沙盒验证
    private let SANDBOX_VERIFY = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeTransactionObserver()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        title = "设置"
        view.backgroundColor = COLOR_ALL_BG
    }
    
    /**
     准备数据
     */
    private func prepareData() {
        
        if JFAccountModel.isLogin() {
            // 第零组
            let group0CellModel1 = JFProfileCellArrowModel(title: "账号与安全", destinationVc: JFSafeViewController.classForCoder())
            let group0CellModel2 = JFProfileCellLabelModel(title: "去除广告", text: JFAccountModel.shareAccount()?.adDsabled == 0 ? "暂未购买" : "已经购买")
            group0CellModel2.operation = { () -> Void in
                self.didTappedBuyCell()
            }
            let group0CellModel3 = JFProfileCellLabelModel(title: "恢复购买", text: JFAccountModel.shareAccount()?.adDsabled == 0 ? "可以尝试恢复" : "已经生效，不用恢复")
            group0CellModel3.operation = { () -> Void in
                self.didTappedRestore()
            }
            let group0 = JFProfileCellGroupModel(cells: [group0CellModel1, group0CellModel2, group0CellModel3])
            
            
            // 第一组
            let group1CellModel1 = JFProfileCellLabelModel(title: "清除缓存", text: "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M")
            group1CellModel1.operation = { () -> Void in
                JFProgressHUD.showWithStatus("正在清理")
                SDImageCache.sharedImageCache().cleanDisk()
                YYImageCache.sharedCache().memoryCache.removeAllObjects()
                YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                    JFProgressHUD.showSuccessWithStatus("清理成功")
                    group1CellModel1.text = "0.00M"
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                })
            }
            let group1CellModel2 = JFProfileCellLabelModel(title: "清除离线下载内容", text: "正在计算...")
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                dispatch_async(dispatch_get_main_queue(), {
                    group1CellModel2.text = "\(String(format: "%.2f", arguments: [JFStoreInfoTool.folderSizeAtPath(DOWNLOAD_PATH)]))M"
                    self.tableView.reloadData()
                })
            }
            group1CellModel2.operation = { () -> Void in
                self.removeCacheVideoData(group1CellModel2)
            }
            let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2])
            
            // 第二组
            let group2CellModel1 = JFProfileCellSwitchModel(title: "允许使用2G/3G/4G网络观看视频", key: KEY_ALLOW_CELLULAR_PLAY)
            let group2CellModel2 = JFProfileCellSwitchModel(title: "允许使用2G/3G/4G网络下载视频", key: KEY_ALLOW_CELLULAR_DOWNLOAD)
            let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
            
            // 第三组
            let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", destinationVc: JFFeedbackViewController.classForCoder())
            let group3CellModel2 = JFProfileCellArrowModel(title: "关于作者", destinationVc: JFAboutMeViewController.classForCoder())
            let group3CellModel3 = JFProfileCellArrowModel(title: "应用评价")
            group3CellModel3.operation = { () -> Void in
                self.jumpToAppstoreCommentPage()
            }
            let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", text: NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String)
            let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
            
            groupModels = [group0, group1, group2, group3]
            tableView.tableFooterView = footerView
        } else {
            // 第一组
            let group1CellModel1 = JFProfileCellLabelModel(title: "清除缓存", text: "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M")
            group1CellModel1.operation = { () -> Void in
                JFProgressHUD.showWithStatus("正在清理")
                SDImageCache.sharedImageCache().cleanDisk()
                YYImageCache.sharedCache().memoryCache.removeAllObjects()
                YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                    JFProgressHUD.showSuccessWithStatus("清理成功")
                    group1CellModel1.text = "0.00M"
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                })
            }
            let group1 = JFProfileCellGroupModel(cells: [group1CellModel1])
            
            // 第二组
            let group2CellModel1 = JFProfileCellSwitchModel(title: "允许使用2G/3G/4G网络观看视频", key: KEY_ALLOW_CELLULAR_PLAY)
            let group2CellModel2 = JFProfileCellSwitchModel(title: "允许使用2G/3G/4G网络下载视频", key: KEY_ALLOW_CELLULAR_DOWNLOAD)
            let group2 = JFProfileCellGroupModel(cells: [group2CellModel1, group2CellModel2])
            
            // 第三组
            let group3CellModel1 = JFProfileCellArrowModel(title: "意见反馈", destinationVc: JFFeedbackViewController.classForCoder())
            let group3CellModel2 = JFProfileCellArrowModel(title: "关于作者", destinationVc: JFAboutMeViewController.classForCoder())
            let group3CellModel3 = JFProfileCellArrowModel(title: "应用评价")
            group3CellModel3.operation = { () -> Void in
                self.jumpToAppstoreCommentPage()
            }
            let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", text: NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String)
            let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
            
            groupModels = [group1, group2, group3]
        }
        
        tableView.reloadData()
    }
    
    /**
     清除下载视频数据
     
     - parameter model: cell对应模型
     */
    func removeCacheVideoData(model: JFProfileCellLabelModel) {
        
        let alertC = UIAlertController(title: "确认要删除所有缓存的视频吗", message: "删除缓存后，可以节省手机磁盘空间，但重新缓存又得WiFi哦", preferredStyle: UIAlertControllerStyle.Alert)
        let confirm = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.Destructive, handler: { (action) in
            JFProgressHUD.showWithStatus("正在清理")
            // 从数据库移除
            JFDALManager.shareManager.removeAllVideo({ (success) in
                if success {
                    // 从本地文件移除
                    let fileManager = NSFileManager.defaultManager()
                    if fileManager.fileExistsAtPath(DOWNLOAD_PATH) {
                        do {
                            try fileManager.removeItemAtPath(DOWNLOAD_PATH)
                            JFProgressHUD.showSuccessWithStatus("清理成功")
                            model.text = "0.00M"
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        } catch {
                            JFProgressHUD.showSuccessWithStatus("清理失败")
                        }
                    } else {
                        JFProgressHUD.showSuccessWithStatus("清理成功")
                    }
                } else {
                    JFProgressHUD.showSuccessWithStatus("清理失败")
                }
            })
        })
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in })
        alertC.addAction(confirm)
        alertC.addAction(cancel)
        presentViewController(alertC, animated: true, completion: { })
        
    }
    
    /**
     购买广告点击事件
     */
    func didTappedBuyCell() {
        if JFAccountModel.shareAccount()?.adDsabled == 0 {
            requestProducts(productID)
        } else {
            JFProgressHUD.showInfoWithStatus("无需重复购买")
        }
    }
    
    /**
     恢复购买
     */
    func didTappedRestore() {
        if JFAccountModel.shareAccount()?.adDsabled == 0 {
            restoreProduct()
        } else {
            JFProgressHUD.showInfoWithStatus("已经激活，无需恢复")
        }
    }
    
    /**
     购买去除广告
     */
    func buyDislodgeAD() {
        JFProgressHUD.showWithStatus("正在操作")
        JFAccountModel.buyDislodgeAD({ (success) in
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    if success {
                        JFProgressHUD.showSuccessWithStatus("购买成功，感谢支持")
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                })
            } else {
                JFProgressHUD.showInfoWithStatus("购买失败，请联系管理员")
            }
            
        })
    }
    
    /**
     跳转到应用商店
     */
    func jumpToAppstoreCommentPage() {
        let store = SKStoreProductViewController()
        store.delegate = self
        store.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier : APPLE_ID]) { (success, error) in
            if success {
                self.presentViewController(store, animated: true, completion: nil)
            } else {
                print(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if JFAccountModel.isLogin() && section == 3 {
            return 20
        } else {
            return 0.1
        }
    }
    
    /**
     退出登录点击
     */
    func didTappedLogoutButton(button: UIButton) {
        
        let alertC = UIAlertController(title: "确定注销登录状态？", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let action1 = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (action) in
            JFAccountModel.logout()
            JFProgressHUD.showSuccessWithStatus("退出成功")
            self.navigationController?.popViewControllerAnimated(true)
        }
        let action2 = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { (action) in
            
        }
        alertC.addAction(action1)
        alertC.addAction(action2)
        presentViewController(alertC, animated: true) {}
    }
    
    // MARK: - 懒加载
    /// 尾部退出视图
    private lazy var footerView: UIView = {
        let logoutButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        logoutButton.addTarget(self, action: #selector(didTappedLogoutButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.setTitle("退出登录", forState: UIControlState.Normal)
        logoutButton.backgroundColor = COLOR_NAV_BG
        logoutButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(logoutButton)
        return footerView
    }()
}

// MARK: - SKStoreProductViewControllerDelegate
extension JFSettingViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
