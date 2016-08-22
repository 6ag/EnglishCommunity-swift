//
//  JFModifyPasswordViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFModifyPasswordViewController: JFBaseTableViewController {
    
    let modifyInfoIdenfitier = "modifyInfoIdenfitier"
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.tableFooterView = footerView
        tableView.backgroundColor = COLOR_ALL_BG
        
        let group1CellModel1 = JFProfileCellModel(title: "原密码")
        let group1CellModel2 = JFProfileCellModel(title: "新密码")
        let group1CellModel3 = JFProfileCellModel(title: "确认新密码")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2, group1CellModel3])
        groupModels = [group1]
    }
    
    /**
     监听文本改变事件
     */
    func didChangeTextField(sender: UITextField) {
        if oldPasswordField.text?.characters.count >= 5 && newPasswordField.text?.characters.count >= 5 && reNewPasswordField.text?.characters.count >= 5 {
            saveButton.enabled = true
            saveButton.backgroundColor = COLOR_NAV_BG
        } else {
            saveButton.enabled = false
            saveButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    /**
     点击了保存
     */
    func didTappedSaveButton(button: UIButton) {
        
        if newPasswordField.text != reNewPasswordField.text {
            JFProgressHUD.showInfoWithStatus("新密码不一致")
            return
        }
        
        JFProgressHUD.showWithStatus("正在修改")
        JFAccountModel.modifyPassword(oldPasswordField.text!, credentialNew: newPasswordField.text!) { (success, tip) in
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    JFProgressHUD.showSuccessWithStatus("修改资料成功")
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
        
    }
    
    // MARK: - 懒加载
    /// 尾部保存视图
    private lazy var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(self.saveButton)
        return footerView
    }()
    
    /// 保存
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        saveButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.setTitle("保存修改", forState: UIControlState.Normal)
        saveButton.enabled = false
        saveButton.backgroundColor = UIColor.grayColor()
        saveButton.layer.cornerRadius = CORNER_RADIUS
        return saveButton
    }()
    
    /// 原密码
    private lazy var oldPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "原密码"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    /// 新密码
    private lazy var newPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "新密码"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
    /// 确认新密码
    private lazy var reNewPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        field.font = UIFont.systemFontOfSize(14)
        field.placeholder = "确认新密码"
        field.secureTextEntry = true
        field.clearButtonMode = .WhileEditing
        return field
    }()
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFModifyPasswordViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.contentView.addSubview(oldPasswordField)
            return cell
        case 1:
            cell.contentView.addSubview(newPasswordField)
            return cell
        case 2:
            cell.contentView.addSubview(reNewPasswordField)
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "修改密码，需要原密码进行验证"
    }
}
