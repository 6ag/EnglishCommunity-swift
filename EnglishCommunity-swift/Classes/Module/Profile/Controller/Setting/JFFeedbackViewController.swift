//
//  JFFeedbackViewController.swift
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


class JFFeedbackViewController: JFBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareUI()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeValueForContentTextView(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        let headerView = UIView()
        headerView.frame = view.bounds
        headerView.backgroundColor = COLOR_ALL_BG
        headerView.addSubview(contentTextView)
        headerView.addSubview(contactTextField)
        headerView.addSubview(commitButton)
        tableView.tableHeaderView = headerView
        
    }
    
    /**
     内容文本改变事件
     */
    @objc fileprivate func didChangeValueForContentTextView(_ notification: Notification) {
        changeCommitState()
    }
    
    /**
     联系人文本改变事件
     */
    @objc fileprivate func didChangeValueForContactTextField(_ field: UITextField) {
        changeCommitState()
    }
    
    /**
     改变提交按钮状态
     */
    fileprivate func changeCommitState() {
        
        if contentTextView.text.characters.count >= 10 && contactTextField.text?.characters.count >= 5 {
            commitButton.isEnabled = true
            commitButton.backgroundColor = COLOR_NAV_BG
        } else {
            commitButton.isEnabled = false
            commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        }
        
    }
    
    /**
     提交按钮点击事件
     */
    @objc fileprivate func didTappedCommitButton(_ commitButton: UIButton) {
        
        tableView.isUserInteractionEnabled = false
        
        JFProgressHUD.showWithStatus("正在提交")
        
        JFNetworkTools.shareNetworkTool.postFeedback(contactTextField.text!, content: contentTextView.text) { (success, result, error) in
            self.tableView.isUserInteractionEnabled = true
            
            guard let result = result, result["status"] == "success" else {
                JFProgressHUD.showSuccessWithStatus("出问题啦！请联系作者")
                return
            }
            
            JFProgressHUD.showSuccessWithStatus("谢谢支持")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    // MARK: - 懒加载
    /// 反馈内容
    lazy var contentTextView: UITextView = {
        let contentTextView = UITextView(frame: CGRect(x: MARGIN, y: 10, width: SCREEN_WIDTH - MARGIN * 2, height: 200))
        contentTextView.layer.cornerRadius = CORNER_RADIUS
        
        return contentTextView
    }()
    
    /// 联系方式
    lazy var contactTextField: UITextField = {
        let contactTextField = UITextField(frame: CGRect(x: MARGIN, y: self.contentTextView.frame.maxY + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40))
        contactTextField.layer.cornerRadius = CORNER_RADIUS
        contactTextField.backgroundColor = UIColor.white
        contactTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: MARGIN, height: 0))
        contactTextField.attributedPlaceholder = NSAttributedString(string: "请输入您的联系方式 QQ/Email/手机", attributes: [
            NSForegroundColorAttributeName : UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1),
            NSFontAttributeName : UIFont.systemFont(ofSize: 14)
            ])
        contactTextField.leftViewMode = .always
        contactTextField.addTarget(self, action: #selector(didChangeValueForContactTextField(_:)), for: UIControlEvents.editingChanged)
        return contactTextField
    }()
    
    /// 提交
    lazy var commitButton: UIButton = {
        let commitButton = UIButton(type: UIButtonType.system)
        commitButton.frame = CGRect(x: MARGIN, y: self.contactTextField.frame.maxY + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40)
        commitButton.setTitle("提交", for: UIControlState())
        commitButton.setTitleColor(UIColor.white, for: UIControlState())
        commitButton.layer.cornerRadius = CORNER_RADIUS
        commitButton.isEnabled = false
        commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        commitButton.addTarget(self, action: #selector(didTappedCommitButton(_:)), for: UIControlEvents.touchUpInside)
        return commitButton
    }()

}
