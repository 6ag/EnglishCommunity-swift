//
//  JFMessageRecord.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/23.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 消息来源用户
class JFByUser: NSObject {
    
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// 头像
    var avatar: String?
    
    /// 性别
    var sex = 0
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}

/// 消息接受者用户
class JFToUser: NSObject {
    
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// 头像
    var avatar: String?
    
    /// 性别
    var sex = 0
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}

class JFMessageRecord: NSObject {
    
    /// 消息来源用户
    var byUser: JFByUser?
    
    /// 消息接受者用户
    var toUser: JFToUser?
    
    /// 消息id
    var id = 0
    
    /// 消息类型 comment at
    var messageType: String?
    
    /// 消息内容
    var content: String?
    
    /// 来源类型 video_info tweet
    var type: String?
    
    /// 来源id
    var sourceId = 0
    
    /// 来源内容
    var sourceContent: String?
    
    /// 是否已经查看
    var looked = 0
    
    /// 缓存cell高度
    var rowHeight: CGFloat = 0
    
    /// 消息时间
    var publishTime: String?
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "byUser" {
            let data = value as! [String : AnyObject]
            self.byUser = JFByUser(dict: data)
            return
        } else if key == "toUser" {
            let data = value as! [String : AnyObject]
            self.toUser = JFToUser(dict: data)
            return
        }
        
        return super.setValue(value, forKey: key)
    }
    
    /**
     获取个人消息列表
     
     - parameter page:     页码
     - parameter finished: 消息列表
     */
    class func getMessageList(_ page: Int, finished: @escaping (_ messageRecords: [JFMessageRecord]?) ->() ) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "page" : page as AnyObject,
            "count" : 20 as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_MESSAGE_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(nil)
                return
            }
            
            if result["status"] == "success" {
                let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
                var messageRecords = [JFMessageRecord]()
                for dict in data {
                    let messageRecord = JFMessageRecord(dict: dict)
                    messageRecords.append(messageRecord)
                }
                finished(messageRecords)
            } else {
                finished(nil)
            }
        }
    }
    
    /**
     获取未读消息数量
     
     - parameter finished: 完成回调
     */
    class func getUnlookedMessageCount(_ finished: @escaping (_ success: Bool, _ count: Int) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            ]
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_UNLOOKED_MESSAGE_COUNT, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false, 0)
                return
            }
            
            if result["status"] == "success" {
                finished(true, result["result"]["unlookedMessageCount"].intValue)
            } else {
                finished(false, 0)
            }
        }
    }
    
    /**
     清理未读消息数量
     
     - parameter finished: 完成回调
     */
    class func clearUnlookedMessage(_ finished: @escaping (_ success: Bool) -> ()) {
        
        if !JFAccountModel.isLogin() {
            return
        }
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(CLEAR_UNLOOKED_MESSAGE, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(false)
                return
            }
            
            if result["status"] == "success" {
                finished(true)
            } else {
                finished(false)
            }
        }
    }
    
}
