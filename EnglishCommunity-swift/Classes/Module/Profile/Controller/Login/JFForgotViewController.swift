//
//  JFForgotViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFForgotViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var retrieveButton: UIButton!
    let buttonColorNormal = UIColor.colorWithHexString("00ac59")
    let buttonColorDisabled = UIColor.colorWithHexString("a2e256")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "用户名", attributes: [NSForegroundColorAttributeName : UIColor.white])
        emailField.attributedPlaceholder = NSAttributedString(string: "邮箱", attributes: [NSForegroundColorAttributeName : UIColor.white])
        usernameView.layer.borderColor = UIColor.white.cgColor
        usernameView.layer.borderWidth = 0.5
        emailView.layer.borderColor = UIColor.white.cgColor
        emailView.layer.borderWidth = 0.5
        didChangeTextField(usernameField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /**
     键盘即将显示
     */
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        let beginHeight = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
        let endHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        
        if beginHeight > 0 && endHeight > 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: -endHeight + (SCREEN_HEIGHT - self.retrieveButton.frame.maxY) - 10)
            }) 
        }
    }
    
    /**
     键盘即将隐藏
     */
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        if usernameField.text?.characters.count ?? 0 >= 5 && emailField.text?.characters.count ?? 0 >= 5 {
            retrieveButton.isEnabled = true
            retrieveButton.backgroundColor = buttonColorNormal
        } else {
            retrieveButton.isEnabled = false
            retrieveButton.backgroundColor = buttonColorDisabled
        }
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTappedRetrieveButton(_ sender: UIButton) {
        view.endEditing(true)
        
        JFProgressHUD.showWithStatus("正在发送")
        JFAccountModel.retrievePasswordEmail(self.usernameField.text!, email: self.emailField.text!) { (success, tip) in
            if success {
                JFProgressHUD.showSuccessWithStatus("发送成功，请查看邮箱")
                self.dismiss(animated: true, completion: nil)
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
        
    }
    
}
