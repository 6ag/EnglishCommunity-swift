//
//  JFSettingViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/20.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage
import StoreKit

class JFSettingViewController: JFBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
            let group0 = JFProfileCellGroupModel(cells: [group0CellModel1])
            
            // 第一组
            let group1CellModel1 = JFProfileCellLabelModel(title: "清除缓存", text: "\(String(format: "%.2f", CGFloat(YYImageCache.sharedCache().diskCache.totalCost()) / 1024 / 1024))M")
            group1CellModel1.operation = { () -> Void in
                JFProgressHUD.showWithStatus("正在清理")
                YYImageCache.sharedCache().diskCache.removeAllObjectsWithBlock({
                    JFProgressHUD.showSuccessWithStatus("清理成功")
                    group1CellModel1.text = "0.00M"
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                })
            }
            let group1CellModel2 = JFProfileCellLabelModel(title: "清除离线下载内容", text: "0.0M")
            group1CellModel2.operation = { () -> Void in
                print("清除下载内容")
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
                let url = NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1146271758")!
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
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
    func didTappedLogoutButton(button: UIButton) -> Void {
        
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
