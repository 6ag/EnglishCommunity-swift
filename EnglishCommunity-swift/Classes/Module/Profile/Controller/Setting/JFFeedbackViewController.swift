//
//  JFFeedbackViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFFeedbackViewController: JFBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didChangeValueForContentTextView(_:)), name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
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
    @objc private func didChangeValueForContentTextView(notification: NSNotification) {
        changeCommitState()
    }
    
    /**
     联系人文本改变事件
     */
    @objc private func didChangeValueForContactTextField(field: UITextField) {
        changeCommitState()
    }
    
    /**
     改变提交按钮状态
     */
    private func changeCommitState() {
        
        if contentTextView.text.characters.count >= 10 && contactTextField.text?.characters.count >= 5 {
            commitButton.enabled = true
            commitButton.backgroundColor = COLOR_NAV_BG
        } else {
            commitButton.enabled = false
            commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        }
        
    }
    
    /**
     提交按钮点击事件
     */
    @objc private func didTappedCommitButton(commitButton: UIButton) {
        
        tableView.userInteractionEnabled = false
        
        JFProgressHUD.showWithStatus("正在提交")
        
        JFNetworkTools.shareNetworkTool.postFeedback(contactTextField.text!, content: contentTextView.text) { (success, result, error) in
            self.tableView.userInteractionEnabled = true
            
            guard let result = result where result["status"] == "success" else {
                JFProgressHUD.showSuccessWithStatus("出问题啦！请联系作者")
                return
            }
            
            JFProgressHUD.showSuccessWithStatus("谢谢支持")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.navigationController?.popViewControllerAnimated(true)
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
        let contactTextField = UITextField(frame: CGRect(x: MARGIN, y: CGRectGetMaxY(self.contentTextView.frame) + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40))
        contactTextField.layer.cornerRadius = CORNER_RADIUS
        contactTextField.backgroundColor = UIColor.whiteColor()
        contactTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: MARGIN, height: 0))
        contactTextField.attributedPlaceholder = NSAttributedString(string: "请输入您的联系方式 QQ/Email/手机", attributes: [
            NSForegroundColorAttributeName : UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1),
            NSFontAttributeName : UIFont.systemFontOfSize(14)
            ])
        contactTextField.leftViewMode = .Always
        contactTextField.addTarget(self, action: #selector(didChangeValueForContactTextField(_:)), forControlEvents: UIControlEvents.EditingChanged)
        return contactTextField
    }()
    
    /// 提交
    lazy var commitButton: UIButton = {
        let commitButton = UIButton(type: UIButtonType.System)
        commitButton.frame = CGRect(x: MARGIN, y: CGRectGetMaxY(self.contactTextField.frame) + MARGIN, width: SCREEN_WIDTH - MARGIN * 2, height: 40)
        commitButton.setTitle("提交", forState: UIControlState.Normal)
        commitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        commitButton.layer.cornerRadius = CORNER_RADIUS
        commitButton.enabled = false
        commitButton.backgroundColor = UIColor(red:0.733,  green:0.733,  blue:0.733, alpha:1)
        commitButton.addTarget(self, action: #selector(didTappedCommitButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return commitButton
    }()

}