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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        didChangeTextField(usernameField)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didChangeTextField(sender: UITextField) {
        if usernameField.text?.characters.count >= 5 && emailField.text?.characters.count >= 5 {
            retrieveButton.enabled = true
            retrieveButton.backgroundColor = COLOR_NAV_BG
        } else {
            retrieveButton.enabled = false
            retrieveButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    @IBAction func didTappedBackButton() {
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didTappedRetrieveButton(sender: UIButton) {
        view.endEditing(true)
        
        JFProgressHUD.showWithStatus("正在发送")
        JFAccountModel.retrievePasswordEmail(self.usernameField.text!, email: self.emailField.text!) { (success, tip) in
            if success {
                JFProgressHUD.showSuccessWithStatus("发送成功，请查看邮箱")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
        
    }
    
}
