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
    
    let buttonColorNormal = UIColor.colorWithHexString("00ac59")
    let buttonColorDisabled = UIColor.colorWithHexString("6d8579")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameView.layer.borderColor = UIColor.whiteColor().CGColor
        usernameView.layer.borderWidth = 0.5
        passwordView.layer.borderColor = UIColor.whiteColor().CGColor
        passwordView.layer.borderWidth = 0.5
        
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
            loginButton.backgroundColor = buttonColorNormal
        } else {
            loginButton.enabled = false
            loginButton.backgroundColor = buttonColorDisabled
        }
    }
    
    /**
     返回
     */
    @IBAction func didTappedBackButton() {
        dismissViewControllerAnimated(true) {}
    }
    
    /**
     注册
     */
    @IBAction func didTappedRegisterButton(sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    /**
     忘记密码
     */
    @IBAction func didTappedForgotButton(sender: UIButton) {
        let forgotVc = JFForgotViewController(nibName: "JFForgotViewController", bundle: nil)
        navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    /**
     QQ登录
     */
    @IBAction func didTappedQQLoginButton(sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeQQ, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.Success {
                self.SDKLoginHandle(state, user: user, type: "qq")
            }
        }
    }
    
    /**
     微博登录
     */
    @IBAction func didTappedSinaLoginButton(sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.TypeSinaWeibo, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.Success {
                self.SDKLoginHandle(state, user: user, type: "weibo")
            }
        }
    }
    
    /**
     第三方登录处理
     
     - parameter state: 授权状态
     - parameter user:  授权用户信息
     - parameter error: 错误对象
     - parameter type:  0:qq 1:weibo
     */
    func SDKLoginHandle(state: SSDKResponseState, user: SSDKUser, type: String) {
        
        let uid = user.uid
        let token = user.credential.token
        let nickname = user.nickname
        let avatar = type == "weibo" ? (user.rawData["avatar_hd"] != nil ? user.rawData["avatar_hd"]! as! String : user.icon) : (user.rawData["figureurl_qq_2"] != nil ? user.rawData["figureurl_qq_2"]! as! String : user.icon)
        let sex = user.gender.rawValue == 0 ? 1 : 0
        
        JFProgressHUD.showWithStatus("正在登录")
        JFAccountModel.thirdAccountLogin(type, openid: uid, token: token, nickname: nickname, avatar: avatar, sex: sex, finished: { (success, tip) in
            if success {
                JFProgressHUD.dismiss()
                NSUserDefaults.standardUserDefaults().setObject(self.usernameField.text, forKey: "")
                NSUserDefaults.standardUserDefaults().setObject(self.passwordField.text, forKey: "")
                self.didTappedBackButton()
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        })
        
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
