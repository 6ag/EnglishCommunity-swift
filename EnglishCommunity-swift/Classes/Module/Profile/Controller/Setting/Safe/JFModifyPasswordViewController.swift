//
//  JFModifyPasswordViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class JFModifyPasswordViewController: JFBaseTableViewController {
    
    let modifyInfoIdenfitier = "modifyInfoIdenfitier"
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.grouped)
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
    func didChangeTextField(_ sender: UITextField) {
        if oldPasswordField.text?.characters.count >= 5 && newPasswordField.text?.characters.count >= 5 && reNewPasswordField.text?.characters.count >= 5 {
            saveButton.isEnabled = true
            saveButton.backgroundColor = COLOR_NAV_BG
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor.gray
        }
    }
    
    /**
     点击了保存
     */
    func didTappedSaveButton(_ button: UIButton) {
        
        if newPasswordField.text != reNewPasswordField.text {
            JFProgressHUD.showInfoWithStatus("新密码不一致")
            return
        }
        
        JFProgressHUD.showWithStatus("正在修改")
        JFAccountModel.modifyPassword(oldPasswordField.text!, credentialNew: newPasswordField.text!) { (success, tip) in
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    JFProgressHUD.showSuccessWithStatus("修改资料成功")
                    self.navigationController?.popToRootViewController(animated: true)
                })
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
        
    }
    
    // MARK: - 懒加载
    /// 尾部保存视图
    fileprivate lazy var footerView: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        footerView.addSubview(self.saveButton)
        return footerView
    }()
    
    /// 保存
    fileprivate lazy var saveButton: UIButton = {
        let saveButton = UIButton(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH - 40, height: 44))
        saveButton.addTarget(self, action: #selector(didTappedSaveButton(_:)), for: UIControlEvents.touchUpInside)
        saveButton.setTitle("保存修改", for: UIControlState())
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor.gray
        saveButton.layer.cornerRadius = CORNER_RADIUS
        return saveButton
    }()
    
    /// 原密码
    fileprivate lazy var oldPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), for: UIControlEvents.editingChanged)
        field.font = UIFont.systemFont(ofSize: 14)
        field.placeholder = "原密码"
        field.isSecureTextEntry = true
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    /// 新密码
    fileprivate lazy var newPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), for: UIControlEvents.editingChanged)
        field.font = UIFont.systemFont(ofSize: 14)
        field.placeholder = "新密码"
        field.isSecureTextEntry = true
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    /// 确认新密码
    fileprivate lazy var reNewPasswordField: UITextField = {
        let field = UITextField(frame: CGRect(x: SCREEN_WIDTH * 0.25, y: 0, width: SCREEN_WIDTH * 0.7, height: 44))
        field.addTarget(self, action: #selector(didChangeTextField(_:)), for: UIControlEvents.editingChanged)
        field.font = UIFont.systemFont(ofSize: 14)
        field.placeholder = "确认新密码"
        field.isSecureTextEntry = true
        field.clearButtonMode = .whileEditing
        return field
    }()
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFModifyPasswordViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "修改密码，需要原密码进行验证"
    }
}
