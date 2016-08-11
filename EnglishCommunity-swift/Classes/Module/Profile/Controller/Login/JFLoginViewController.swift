//
//  JFLoginViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop

class JFLoginViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        effectView.frame = SCREEN_BOUNDS
        bgImageView.addSubview(effectView)
        
        // 设置保存的账号
        usernameField.text = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        passwordField.text = NSUserDefaults.standardUserDefaults().objectForKey("password") as? String
        
        didChangeTextField(usernameField)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    /**
     登录按钮点击事件
     */
    @IBAction func didTappedLoginButton(button: UIButton) {
        
        view.endEditing(true)
        
        JFProgressHUD.showWithStatus("正在登录")
        JFAccountModel.normalAccountLogin("username", username: usernameField.text!, password: passwordField.text!) { (success, tip) in
            if success {
                JFProgressHUD.dismiss()
                NSUserDefaults.standardUserDefaults().setObject(self.usernameField.text, forKey: "username")
                NSUserDefaults.standardUserDefaults().setObject(self.passwordField.text, forKey: "password")
                self.didTappedBackButton()
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
    }
    
    @IBAction func didChangeTextField(sender: UITextField) {
        
        if usernameField.text?.characters.count >= 5 && passwordField.text?.characters.count > 5 {
            loginButton.enabled = true
            loginButton.backgroundColor = UIColor(red: 32/255.0, green: 170/255.0, blue: 238/255.0, alpha: 1)
        } else {
            loginButton.enabled = false
            loginButton.backgroundColor = UIColor.grayColor()
        }
    }
    
    @IBAction func didTappedBackButton() {
        dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func didTappedRegisterButton(sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    @IBAction func didTappedForgotButton(sender: UIButton) {
        let forgotVc = JFForgotViewController(nibName: "JFForgotViewController", bundle: nil)
        navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    @IBAction func didTappedQQLoginButton(sender: UIButton) {
        //        ShareSDK.getUserInfo(SSDKPlatformType.TypeQQ, conditional: nil) { (state, user, error) in
        //            if state == SSDKResponseState.Success {
        //                self.SDKLoginHandle(user.nickname, avatar: user.rawData["figureurl_qq_2"] != nil ? user.rawData["figureurl_qq_2"]! as! String : user.icon, uid: user.uid, type: 1)
        //            } else {
        //                self.didTappedBackButton()
        //            }
        //        }
    }
    
    @IBAction func didTappedSinaLoginButton(sender: UIButton) {
        //        ShareSDK.getUserInfo(SSDKPlatformType.TypeSinaWeibo, conditional: nil) { (state, user, error) in
        //            if state == SSDKResponseState.Success {
        //                self.SDKLoginHandle(user.nickname, avatar: user.rawData["avatar_hd"] != nil ? user.rawData["avatar_hd"]! as! String : user.icon, uid: user.uid, type: 2)
        //            } else {
        //                self.didTappedBackButton()
        //            }
        //        }
    }
    
    /**
     第三方登录授权处理
     
     - parameter nickname: 昵称
     - parameter avatar:   头像url
     - parameter uid:      唯一标识
     */
    func SDKLoginHandle(nickname: String, avatar: String, uid: String, type: Int) {
        
    }
    
}

// MARK: - JFRegisterViewControllerDelegate
extension JFLoginViewController: JFRegisterViewControllerDelegate {
    
    /**
     注册成功回调
     
     - parameter username: 凭证唯一标示
     - parameter password: 密码
     */
    func registerSuccess(username: String, password: String) {
        usernameField.text = username
        passwordField.text = password
        didChangeTextField(usernameField)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.didTappedLoginButton(self.loginButton)
        }
    }
}
