//
//  JFSafeViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFSafeViewController: JFBaseTableViewController {
    
    let modifyInfoIdenfitier = "modifyInfoIdenfitier"
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let group1Cell1 = JFProfileCellLabelModel(title: "id号", text: "\(JFAccountModel.shareAccount()!.id)")
        let group1Cell2 = JFProfileCellArrowModel(title: "修改密码", destinationVc: JFModifyPasswordViewController.classForCoder())
        let group1 = JFProfileCellGroupModel(cells: [group1Cell1, group1Cell2])
        
        let group2Cell1 = JFProfileCellArrowModel(title: "QQ号", text: JFAccountModel.shareAccount()!.qqBinding == 0 ? "未绑定" : "已绑定", destinationVc: UIViewController.classForCoder())
        group2Cell1.operation = {() -> Void in
//            JFProgressHUD.showInfoWithStatus("暂不支持微信绑定")
        }
        let group2Cell2 = JFProfileCellArrowModel(title: "微信", text: JFAccountModel.shareAccount()!.weixinBinding == 0 ? "未绑定" : "已绑定", destinationVc: UIViewController.classForCoder())
        group2Cell2.operation = {() -> Void in
//            JFProgressHUD.showInfoWithStatus("暂不支持微信绑定")
        }
        let group2Cell3 = JFProfileCellArrowModel(title: "微博", text: JFAccountModel.shareAccount()!.weiboBinding == 0 ? "未绑定" : "已绑定", destinationVc: UIViewController.classForCoder())
        group2Cell3.operation = {() -> Void in
//            JFProgressHUD.showInfoWithStatus("暂不支持微信绑定")
        }
        let group2Cell4 = JFProfileCellArrowModel(title: "手机号", text: JFAccountModel.shareAccount()!.mobileBinding == 0 ? "未绑定" : JFAccountModel.shareAccount()!.mobile!, destinationVc: UIViewController.classForCoder())
        group2Cell4.operation = {() -> Void in
//            JFProgressHUD.showInfoWithStatus("暂不支持微信绑定")
        }
        let group2Cell5 = JFProfileCellArrowModel(title: "邮箱", text: JFAccountModel.shareAccount()!.emailBinding == 0 ? "未绑定" : JFAccountModel.shareAccount()!.email!, destinationVc: UIViewController.classForCoder())
        group2Cell5.operation = {() -> Void in
//            JFProgressHUD.showInfoWithStatus("暂不支持微信绑定")
        }
        let group2 = JFProfileCellGroupModel(cells: [group2Cell1, group2Cell2, group2Cell3, group2Cell4, group2Cell5])
        group2.footerTitle = "绑定后可以用多种方式登录同一个账号，让登录更方便！"
        
        groupModels = [group1, group2]
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 45
        } else {
            return 0.1
        }
    }
    
}
