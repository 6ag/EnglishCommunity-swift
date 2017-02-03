//
//  JFAccountModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/17.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAccountModel: NSObject, NSCoding {
    
    // MARK: - 属性
    /// 令牌
    var token: String?
    
    /// token过期时间
    var expiryTime: String?
    
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
    
    /// 是否显示广告 0显示 1不显示
    var adDsabled = 0
    
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
    
    /// 粉丝数量
    var followersCount = 0
    
    /// 关注数量
    var followingCount = 0
    
    /// 是否已经关注了某个用户
    var followed = 0
    
    // MARK: - 转模型
    // KVC 字典转模型
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    // MARK: - 外部调用接口
    /**
     获取用户对象 （这可不是单例哦，只是对象静态化了，保证在内存中不释放）
     */
    static func shareAccount() -> JFAccountModel? {
        if userAccount == nil {
            userAccount = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? JFAccountModel
            return userAccount
        } else {
            return userAccount
        }
    }
    
    /**
     是否已经登录
     */
    class func isLogin() -> Bool {
        return JFAccountModel.shareAccount() != nil
    }
    
    /**
     注销清理
     */
    class func logout() {
        
        // 取消第三方登录授权
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeQQ)
        ShareSDK.cancelAuthorize(SSDKPlatformType.typeSinaWeibo)
        
        // 清除内存中的账户数据和归档中的数据
        JFAccountModel.userAccount = nil
        do {
            try FileManager.default.removeItem(atPath: JFAccountModel.accountPath)
        } catch {
            log("退出异常")
        }
    }
    
    /**
     检查token有效期
     */
    class func checkToken() {
        if JFAccountModel.isLogin() {
            guard let expiryTime = JFAccountModel.shareAccount()?.expiryTime else {
                return
            }
            
            // 获取当前时间的时间戳
            let nowTime = Date().timeIntervalSince1970
            if nowTime > TimeInterval(expiryTime) ?? TimeInterval() {
                JFAccountModel.logout()
            }
        }
    }
    
    // MARK: - 内部处理方法
    /**
     登录保存用户信息
     */
    fileprivate func saveUserInfo() {
        // 保存到内存中
        JFAccountModel.userAccount = self
        // 归档用户信息
        saveAccount()
    }
    
    // 持久保存到内存中
    fileprivate static var userAccount: JFAccountModel?
    
    /// 归档账号的路径
    static let accountPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! + "/Account.plist"
    
    /**
     归档用户数据
     */
    fileprivate func saveAccount() {
        NSKeyedArchiver.archiveRootObject(self, toFile: JFAccountModel.accountPath)
    }
    
    // MARK: - 归档和解档
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token_key")
        aCoder.encode(expiryTime, forKey: "expiry_time_key")
        aCoder.encodeCInt(Int32(id), forKey: "id_key")
        aCoder.encode(nickname, forKey: "nickname_key")
        aCoder.encode(say, forKey: "say_key")
        aCoder.encode(avatar, forKey: "avatar_key")
        aCoder.encode(mobile, forKey: "mobile_key")
        aCoder.encode(email, forKey: "email_key")
        aCoder.encodeCInt(Int32(sex), forKey: "sex_key")
        aCoder.encodeCInt(Int32(adDsabled), forKey: "ad_dsabled_key")
        aCoder.encodeCInt(Int32(qqBinding), forKey: "qq_binding_key")
        aCoder.encodeCInt(Int32(weixinBinding), forKey: "weixin_binding_key")
        aCoder.encodeCInt(Int32(weiboBinding), forKey: "weibo_binding_key")
        aCoder.encodeCInt(Int32(emailBinding), forKey: "email_binding_key")
        aCoder.encodeCInt(Int32(mobileBinding), forKey: "mobile_binding_key")
        aCoder.encodeCInt(Int32(followersCount), forKey: "followers_count_key")
        aCoder.encodeCInt(Int32(followingCount), forKey: "following_count_key")
        aCoder.encode(registerTime, forKey: "register_time_key")
        aCoder.encode(lastLoginTime, forKey: "last_login_time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        token = aDecoder.decodeObject(forKey: "token_key") as? String
        expiryTime = aDecoder.decodeObject(forKey: "expiry_time_key") as? String
        id = Int(aDecoder.decodeCInt(forKey: "id_key"))
        nickname = aDecoder.decodeObject(forKey: "nickname_key") as? String
        say = aDecoder.decodeObject(forKey: "say_key") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar_key") as? String
        mobile = aDecoder.decodeObject(forKey: "mobile_key") as? String
        email = aDecoder.decodeObject(forKey: "email_key") as? String
        sex = Int(aDecoder.decodeCInt(forKey: "sex_key"))
        adDsabled = Int(aDecoder.decodeCInt(forKey: "ad_dsabled_key"))
        qqBinding = Int(aDecoder.decodeCInt(forKey: "qq_binding_key"))
        weixinBinding = Int(aDecoder.decodeCInt(forKey: "weixin_binding_key"))
        weiboBinding = Int(aDecoder.decodeCInt(forKey: "weibo_binding_key"))
        emailBinding = Int(aDecoder.decodeCInt(forKey: "email_binding_key"))
        mobileBinding = Int(aDecoder.decodeCInt(forKey: "mobile_binding_key"))
        followersCount = Int(aDecoder.decodeCInt(forKey: "followers_count_key"))
        followingCount = Int(aDecoder.decodeCInt(forKey: "following_count_key"))
        registerTime = aDecoder.decodeObject(forKey: "register_time_key") as? String
        lastLoginTime = aDecoder.decodeObject(forKey: "last_login_time") as? String
    }
}

// MARK: - 各种网络请求
extension JFAccountModel {
    
    /**
     修改用户密码
     
     - parameter credentialOld: 旧密码
     - parameter credentialNew: 新密码
     - parameter finished:      完成回调
     */
    class func modifyPassword(_ credentialOld: String, credentialNew: String, finished: @escaping (_ success: Bool, _ tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "credential_old" : credentialOld as AnyObject,
            "credential_new" : credentialNew as AnyObject
            ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(MODIFY_USER_PASSWORD, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false, "您的网络不给力哦")
                return
            }
            
            if result["status"] == "success" {
                finished(true, "修改密码成功")
            } else {
                finished(false, result["message"].stringValue)
            }
            
        }
        
    }
    
    /**
     发送重置密码邮箱
     
     - parameter username: 账号
     - parameter email:    绑定邮箱
     - parameter finished: 完成回调
     */
    class func retrievePasswordEmail(_ username: String, email: String, finished: @escaping (_ success: Bool, _ tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "identifier" : username as AnyObject,
            "email" : email as AnyObject,
        ]
        
        JFNetworkTools.shareNetworkTool.post(RETRIEVE_PASSWORD_EMAIL, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false, "您的网络不给力哦")
                return
            }
            
            if result["status"] == "success" {
                finished(true, "发送成功，请查看邮件")
            } else {
                finished(false, result["message"].stringValue)
            }
            
        }
        
    }
    
    /**
     普通账号注册
     
     - parameter type:     注册类型
     - parameter username: 用户名/邮箱/手机号码等
     - parameter password: 密码
     - parameter finished: 完成回调
     */
    class func normalAccountRegister(_ type: String, username: String, password: String, finished: @escaping (_ success: Bool, _ tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "identifier" : username as AnyObject,
            "credential" : password as AnyObject,
            "type" : type as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.post(REGISTER, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false, "您的网络不给力哦")
                return
            }
            
            if result["status"] == "success" {
                finished(true, "注册成功")
            } else {
                finished(false, result["message"].stringValue)
            }
            
        }
    }
    
    /**
     普通账号登录
     
     - parameter type:     登录类型
     - parameter username: 用户名/邮箱/手机号码
     - parameter password: 密码
     - parameter finished: 完成回调
     */
    class func normalAccountLogin(_ type: String, username: String, password: String, finished: @escaping (_ success: Bool, _ tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "identifier" : username as AnyObject,
            "credential" : password as AnyObject,
            "type" : type as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
            
            log(result)
            guard let result = result else {
                finished(false, "您的网络不给力哦")
                return
            }
            
            if result["status"] == "success" {
                let account = JFAccountModel(dict: result["result"].dictionaryObject!)
                account.saveUserInfo()
                finished(true, "登录成功")
            } else {
                finished(false, result["message"].stringValue)
            }
            
        }
    }
    
    /**
     第三方登录
     
     - parameter type:     类型 qq weibo
     - parameter openid:   uid
     - parameter token:    token
     - parameter nickname: 昵称
     - parameter avatar:   头像
     - parameter sex:      性别 0:女 1:男
     - parameter finished: 完成回调
     */
    class func thirdAccountLogin(_ type: String, openid: String, token: String, nickname: String, avatar: String, sex: Int, finished: @escaping (_ success: Bool, _ tip: String) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "type" : type as AnyObject,
            "identifier" : openid as AnyObject,
            "token" : token as AnyObject,
            "nickname" : nickname as AnyObject,
            "avatar" : avatar as AnyObject,
            "sex" : sex as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.post(LOGIN, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false, "您的网络不给力哦")
                return
            }
            
            if result["status"] == "success" {
                let account = JFAccountModel(dict: result["result"].dictionaryObject!)
                account.saveUserInfo()
                finished(true, "登录成功")
            } else {
                finished(false, result["message"].stringValue)
            }
            
        }
    }
    
    /**
     上传用户头像
     
     - parameter userId:      用户id
     - parameter avatarImage: 头像图片对象
     */
    class func uploadUserAvatar(_ avatarImage: UIImage, finished: @escaping (_ success: Bool) -> ()) {
        
        let imageData = UIImageJPEGRepresentation(avatarImage, 1)!
        let imageBase64 = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "photo" : imageBase64 as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(UPLOAD_USER_AVATAR, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(false)
                return
            }
            
            finished(true)
        }
    }
    
    /**
     修改更新用户信息
     
     - parameter nickname: 昵称
     - parameter sex:      性别 0女 1男
     - parameter say:      个性签名
     - parameter finished: 完成回调
     */
    class func updateUserInfo(_ nickname: String, sex: Int, say: String, finished: @escaping (_ success: Bool) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "nickname" : nickname as AnyObject,
            "sex" : sex as AnyObject,
            "say" : say as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(UPDATE_USER_INFOMATION, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(false)
                return
            }
            
            finished(true)
        }
    }
    
    /**
     获取自己的用户信息 - 获取成功会更新本地用户信息
     
     - parameter finished: 完成回调
     */
    class func getSelfUserInfo(_ finished: @escaping (_ success: Bool) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_SELF_USER_INFOMATION, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(false)
                return
            }
            
            // 更新用户信息而不更新token
            let account = JFAccountModel(dict: result["result"].dictionaryObject!)
            account.token = JFAccountModel.shareAccount()?.token
            account.saveUserInfo()
            
            finished(true)
        }
    }
    
    /**
     获取他人的用户信息 - 获取成功返回给调用者
     
     - parameter finished: 完成回调
     */
    class func getOtherUserInfo(_ otherUserId: Int, finished: @escaping (_ userInfo: JFAccountModel?) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()?.id as AnyObject? ?? 0 as AnyObject,
            "other_user_id" : otherUserId as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_OTHER_USER_INFOMATION, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            let userInfo = JFAccountModel(dict: result["result"].dictionaryObject!)
            finished(userInfo)
        }
    }
    
    /**
     购买去除广告服务
     
     - parameter finished: 完成回调
     */
    class func buyDislodgeAD(_ finished: @escaping (_ success: Bool) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
        ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(BUY_DISLODGE_AD, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(false)
                return
            }
            
            finished(true)
        }
        
    }
}
