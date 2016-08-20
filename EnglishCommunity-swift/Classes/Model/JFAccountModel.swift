//
//  JFAccountModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/17.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAccountModel: NSObject, NSCoding {
    
    /// 令牌
    var token: String?
    
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// 心情寄语
    var say: String?
    
    /// 头像
    var avatar: String?
    
    /// 电话号码
    var mobile: String?
    
    /// 邮箱
    var email: String?
    
    /// 性别
    var sex: Int = 0
    
    /// qq登录
    var qqBinding: Int = 0
    
    /// 微信登录
    var weixinBinding: Int = 0
    
    /// 微博登录
    var weiboBinding: Int = 0
    
    /// 邮箱登录
    var emailBinding: Int = 0
    
    /// 手机登录
    var mobileBinding: Int = 0
    
    /// 注册时间
    var registerTime: String?
    
    /// 最后一次登录时间
    var lastLoginTime: String?
    
    // KVC 字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     注销清理
     */
    class func logout() {
//        ShareSDK.cancelAuthorize(SSDKPlatformType.TypeQQ)
//        ShareSDK.cancelAuthorize(SSDKPlatformType.TypeSinaWeibo)
        
        // 清除内存中的账号对象和归档
        JFAccountModel.userAccount = nil
        do {
            try NSFileManager.defaultManager().removeItemAtPath(JFAccountModel.accountPath)
        } catch {
            print("退出异常")
        }
    }
    
    /**
     是否已经登录
     */
    class func isLogin() -> Bool {
        return JFAccountModel.shareAccount() != nil
    }
    
    /**
     登录保存用户信息
     */
    func updateUserInfo() {
        // 保存到内存中
        JFAccountModel.userAccount = self
        // 归档用户信息
        saveAccount()
    }
    
    // MARK: - 保存对象
    func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: JFAccountModel.accountPath)
    }
    
    // 持久保存到内存中
    private static var userAccount: JFAccountModel?
    
    /// 归档账号的路径
    static let accountPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! + "/Account.plist"
    
    /**
     获取用户对象 （这可不是单例哦，只是对象静态化了，保证在内存中不释放）
     */
    static func shareAccount() -> JFAccountModel? {
        if userAccount == nil {
            userAccount = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? JFAccountModel
            return userAccount
        } else {
            return userAccount
        }
    }
    
    // MARK: - 归档和解档
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(token, forKey: "token_key")
        aCoder.encodeInt(Int32(id), forKey: "id_key")
        aCoder.encodeObject(nickname, forKey: "nickname_key")
        aCoder.encodeObject(say, forKey: "say_key")
        aCoder.encodeObject(avatar, forKey: "avatar_key")
        aCoder.encodeObject(mobile, forKey: "mobile_key")
        aCoder.encodeObject(email, forKey: "email_key")
        aCoder.encodeInt(Int32(sex), forKey: "sex_key")
        aCoder.encodeInt(Int32(qqBinding), forKey: "qq_binding_key")
        aCoder.encodeInt(Int32(weixinBinding), forKey: "weixin_binding_key")
        aCoder.encodeInt(Int32(weiboBinding), forKey: "weibo_binding_key")
        aCoder.encodeInt(Int32(emailBinding), forKey: "email_binding_key")
        aCoder.encodeInt(Int32(mobileBinding), forKey: "mobile_binding_key")
        aCoder.encodeObject(registerTime, forKey: "register_time_key")
        aCoder.encodeObject(lastLoginTime, forKey: "last_login_time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObjectForKey("token_key") as? String
        id = Int(aDecoder.decodeIntForKey("id_key"))
        nickname = aDecoder.decodeObjectForKey("nickname_key") as? String
        say = aDecoder.decodeObjectForKey("say_key") as? String
        avatar = aDecoder.decodeObjectForKey("avatar_key") as? String
        mobile = aDecoder.decodeObjectForKey("mobile_key") as? String
        email = aDecoder.decodeObjectForKey("email_key") as? String
        sex = Int(aDecoder.decodeIntForKey("sex_key"))
        qqBinding = Int(aDecoder.decodeIntForKey("qq_binding_key"))
        weixinBinding = Int(aDecoder.decodeIntForKey("weixin_binding_key"))
        weiboBinding = Int(aDecoder.decodeIntForKey("weibo_binding_key"))
        emailBinding = Int(aDecoder.decodeIntForKey("email_binding_key"))
        mobileBinding = Int(aDecoder.decodeIntForKey("mobile_binding_key"))
        registerTime = aDecoder.decodeObjectForKey("register_time_key") as? String
        lastLoginTime = aDecoder.decodeObjectForKey("last_login_time") as? String
    }
}

// MARK: - 各种网络请求
extension JFAccountModel {
    
    /**
     获取最新用户信息
     
     - parameter finished: 完成回调
     */
    class func getNewUserInfo(finished: (success: Bool) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_USER_INFOMATION, parameters: ["user_id" : JFAccountModel.shareAccount()!.id]) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                finished(success: false)
                return
            }
            
            let account = JFAccountModel(dict: result["result"].dictionaryObject!)
            account.updateUserInfo()
            finished(success: true)
        }
    }
    
    /**
     更新用户信息
     
     - parameter nickname: 昵称
     - parameter sex:      性别 0女 1男
     - parameter say:      个性签名
     - parameter finished: 完成回调
     */
    class func updateUserInfo(nickname: String, sex: Int, say: String, finished: (success: Bool) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "nickname" : nickname,
            "sex" : sex,
            "say" : say
        ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(UPDATE_USER_INFOMATION, parameters: parameters) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                finished(success: false)
                return
            }
            
            finished(success: true)
        }
    }
    
    /**
     普通账号注册
     
     - parameter type:     注册类型
     - parameter username: 用户名/邮箱/手机号码等
     - parameter password: 密码
     - parameter finished: 完成回调
     */
    class func normalAccountRegister(type: String, username: String, password: String, finished: (success: Bool, tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "identifier" : username,
            "credential" : password,
            "type" : type
            ]
        
        JFNetworkTools.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
            
            guard let _ = result where success == true && result!["status"] == "success" else {
                finished(success: false, tip: result!["message"].string!)
                return
            }
            
            finished(success: true, tip: "注册成功")
        }
    }
    
    /**
     普通账号登录
     
     - parameter type:     登录类型
     - parameter username: 用户名/邮箱/手机号码
     - parameter password: 密码
     - parameter finished: 完成回调
     */
    class func normalAccountLogin(type: String, username: String, password: String, finished: (success: Bool, tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "identifier" : username,
            "credential" : password,
            "type" : type
            ]
        
        JFNetworkTools.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
            guard let _ = result where success == true && result!["status"] == "success" else {
                finished(success: false, tip: result!["message"].string!)
                return
            }
            
            let account = JFAccountModel(dict: result!["result"].dictionaryObject!)
            account.updateUserInfo()
            finished(success: true, tip: "登录成功")
        }
    }
    
    /**
     上传用户头像
     
     - parameter userId:      用户id
     - parameter avatarImage: 头像图片对象
     */
    class func uploadUserAvatar(avatarImage: UIImage, finished: (success: Bool) -> ()) {
        
        let imageData = UIImageJPEGRepresentation(avatarImage, 1)!
        let imageBase64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "photo" : imageBase64
        ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(UPLOAD_USER_AVATAR, parameters: parameters) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                finished(success: false)
                return
            }
            
            finished(success: true)
        }
    }
}