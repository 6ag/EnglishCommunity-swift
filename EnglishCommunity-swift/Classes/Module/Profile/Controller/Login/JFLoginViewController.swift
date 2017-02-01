//
//  JFLoginViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import pop
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        
        usernameView.layer.borderColor = UIColor.white.cgColor
        usernameView.layer.borderWidth = 0.5
        passwordView.layer.borderColor = UIColor.white.cgColor
        passwordView.layer.borderWidth = 0.5
        
        // 设置保存的账号
        usernameField.text = UserDefaults.standard.object(forKey: "username") as? String
        passwordField.text = UserDefaults.standard.object(forKey: "password") as? String
        
        didChangeTextField(usernameField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
                self.view.transform = CGAffineTransform(translationX: 0, y: -endHeight + (SCREEN_HEIGHT - self.loginButton.frame.maxY) - 10)
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
    
    /**
     登录按钮点击事件
     */
    @IBAction func didTappedLoginButton(_ button: UIButton) {
        
        view.endEditing(true)
        
        JFProgressHUD.showWithStatus("正在登录")
        JFAccountModel.normalAccountLogin("username", username: usernameField.text!, password: passwordField.text!) { (success, tip) in
            if success {
                JFProgressHUD.dismiss()
                UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                UserDefaults.standard.set(self.passwordField.text, forKey: "password")
                self.didTappedBackButton()
            } else {
                JFProgressHUD.showInfoWithStatus(tip)
            }
        }
    }
    
    @IBAction func didChangeTextField(_ sender: UITextField) {
        
        if usernameField.text?.characters.count >= 5 && passwordField.text?.characters.count > 5 {
            loginButton.isEnabled = true
            loginButton.backgroundColor = buttonColorNormal
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = buttonColorDisabled
        }
    }
    
    /**
     返回
     */
    @IBAction func didTappedBackButton() {
        dismiss(animated: true) {}
    }
    
    /**
     注册
     */
    @IBAction func didTappedRegisterButton(_ sender: UIButton) {
        let registerVc = JFRegisterViewController(nibName: "JFRegisterViewController", bundle: nil)
        registerVc.delegate = self
        navigationController?.pushViewController(registerVc, animated: true)
    }
    
    /**
     忘记密码
     */
    @IBAction func didTappedForgotButton(_ sender: UIButton) {
        let forgotVc = JFForgotViewController(nibName: "JFForgotViewController", bundle: nil)
        navigationController?.pushViewController(forgotVc, animated: true)
    }
    
    /**
     QQ登录
     */
    @IBAction func didTappedQQLoginButton(_ sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeQQ, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle(state, user: user!, type: "qq")
            }
        }
    }
    
    /**
     微博登录
     */
    @IBAction func didTappedSinaLoginButton(_ sender: UIButton) {
        ShareSDK.getUserInfo(SSDKPlatformType.typeSinaWeibo, conditional: nil) { (state, user, error) in
            if state == SSDKResponseState.success {
                self.SDKLoginHandle(state, user: user!, type: "weibo")
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
    func SDKLoginHandle(_ state: SSDKResponseState, user: SSDKUser, type: String) {
        
        let uid = user.uid ?? ""
        let token = user.credential.token ?? ""
        let nickname = user.nickname ?? ""
        let avatar = type == "weibo" ? (user.rawData["avatar_hd"] != nil ? user.rawData["avatar_hd"]! as! String : user.icon) : (user.rawData["figureurl_qq_2"] != nil ? user.rawData["figureurl_qq_2"]! as! String : user.icon)
        let sex = user.gender.rawValue == 0 ? 1 : 0
        
        JFProgressHUD.showWithStatus("正在登录")
        JFAccountModel.thirdAccountLogin(type, openid: uid, token: token, nickname: nickname, avatar: avatar ?? "", sex: sex, finished: { (success, tip) in
            if success {
                JFProgressHUD.dismiss()
                UserDefaults.standard.set(self.usernameField.text, forKey: "")
                UserDefaults.standard.set(self.passwordField.text, forKey: "")
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
    func registerSuccess(_ username: String, password: String) {
        usernameField.text = username
        passwordField.text = password
        didChangeTextField(usernameField)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.didTappedLoginButton(self.loginButton)
        }
    }
}
