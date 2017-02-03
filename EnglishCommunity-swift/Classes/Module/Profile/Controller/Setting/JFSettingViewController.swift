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

class JFSettingViewController: JFBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        title = "设置"
        view.backgroundColor = COLOR_ALL_BG
    }
    
    /**
     准备数据
     */
    fileprivate func prepareData() {
        
        if JFAccountModel.isLogin() {
            // 第零组
            let group0CellModel1 = JFProfileCellArrowModel(title: "账号与安全", destinationVc: JFSafeViewController.classForCoder())
            let group0 = JFProfileCellGroupModel(cells: [group0CellModel1])
            
            // 第一组
            let group1CellModel1 = JFProfileCellLabelModel(title: "清除缓存", text: "\(String(format: "%.2f", CGFloat(YYImageCache.shared().diskCache.totalCost()) / 1024 / 1024))M")
            group1CellModel1.operation = { () -> Void in
                JFProgressHUD.showWithStatus("正在清理")
                SDImageCache.shared().cleanDisk()
                YYImageCache.shared().memoryCache.removeAllObjects()
                YYImageCache.shared().diskCache.removeAllObjects({
                    JFProgressHUD.showSuccessWithStatus("清理成功")
                    group1CellModel1.text = "0.00M"
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                })
            }
            let group1CellModel2 = JFProfileCellLabelModel(title: "清除离线下载内容", text: "正在计算...")
            DispatchQueue.main.async {
                group1CellModel2.text = "\(String(format: "%.2f", arguments: [JFStoreInfoTool.folderSize(atPath: DOWNLOAD_PATH)]))M"
                self.tableView.reloadData()
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
            let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", text: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
            let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
            
            groupModels = [group0, group1, group2, group3]
            tableView.tableFooterView = footerView
        } else {
            // 第一组
            let group1CellModel1 = JFProfileCellLabelModel(title: "清除缓存", text: "\(String(format: "%.2f", CGFloat(YYImageCache.shared().diskCache.totalCost()) / 1024 / 1024))M")
            group1CellModel1.operation = { () -> Void in
                JFProgressHUD.showWithStatus("正在清理")
                SDImageCache.shared().cleanDisk()
                YYImageCache.shared().memoryCache.removeAllObjects()
                YYImageCache.shared().diskCache.removeAllObjects({
                    JFProgressHUD.showSuccessWithStatus("清理成功")
                    group1CellModel1.text = "0.00M"
                    DispatchQueue.main.async(execute: {
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
            let group3CellModel4 = JFProfileCellLabelModel(title: "当前版本", text: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
            let group3 = JFProfileCellGroupModel(cells: [group3CellModel1, group3CellModel2, group3CellModel3, group3CellModel4])
            
            groupModels = [group1, group2, group3]
        }
        
        tableView.reloadData()
    }
    
    /**
     清除下载视频数据
     
     - parameter model: cell对应模型
     */
    func removeCacheVideoData(_ model: JFProfileCellLabelModel) {
        
        let alertC = UIAlertController(title: "确认要删除所有缓存的视频吗", message: "删除缓存后，可以节省手机磁盘空间，但重新缓存又得WiFi哦", preferredStyle: UIAlertControllerStyle.alert)
        let confirm = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.destructive, handler: { (action) in
            JFProgressHUD.showWithStatus("正在清理")
            // 从数据库移除
            JFDALManager.shareManager.removeAllVideo({ (success) in
                if success {
                    // 从本地文件移除
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: DOWNLOAD_PATH) {
                        do {
                            try fileManager.removeItem(atPath: DOWNLOAD_PATH)
                            JFProgressHUD.showSuccessWithStatus("清理成功")
                            model.text = "0.00M"
                            DispatchQueue.main.async(execute: {
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
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in })
        alertC.addAction(confirm)
        alertC.addAction(cancel)
        present(alertC, animated: true, completion: { })
        
    }
        
    /**
     跳转到应用商店
     */
    func jumpToAppstoreCommentPage() {
        let store = SKStoreProductViewController()
        store.delegate = self
        store.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : APPLE_ID]) { (success, error) in
            if success {
                self.present(store, animated: true, completion: nil)
            } else {
                log(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if JFAccountModel.isLogin() && section == 3 {
            return 20
        } else {
            return 0.1
        }
    }
    
    /**
     退出登录点击
     */
    func didTappedLogoutButton(_ button: UIButton) {
        
        let alertC = UIAlertController(title: "确定注销登录状态？", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action1 = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            JFAccountModel.logout()
            JFProgressHUD.showSuccessWithStatus("退出成功")
            self.navigationController?.popViewController(animated: true)
        }
        let action2 = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        alertC.addAction(action1)
        alertC.addAction(action2)
        present(alertC, animated: true) {}
    }
    
    // MARK: - 懒加载
    /// 尾部退出视图
    fileprivate lazy var footerView: UIView = {
        let logoutButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        logoutButton.addTarget(self, action: #selector(didTappedLogoutButton(_:)), for: UIControlEvents.touchUpInside)
        logoutButton.setTitle("退出登录", for: UIControlState())
        logoutButton.backgroundColor = COLOR_NAV_BG
        logoutButton.layer.cornerRadius = CORNER_RADIUS
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(logoutButton)
        return footerView
    }()
}

// MARK: - SKStoreProductViewControllerDelegate
extension JFSettingViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true, completion: nil)
    }
}
