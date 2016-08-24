//
//  JFComment.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

/// 评论回复人
class JFCommentAuthor: NSObject {
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// 头像
    var avatar: String?
    
    /// 性别
    var sex = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}

/// 评论被回复的人
class JFCommentExtendsAuthor: NSObject {
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// 头像
    var avatar: String?
    
    /// 性别
    var sex = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}

/// 评论模型
class JFComment: NSObject {
    
    /// 评论回复人
    var author: JFCommentAuthor?
    
    /// 评论被回复人
    var extendsAuthor: JFCommentExtendsAuthor?
    
    /// 评论id
    var id = 0
    
    /// 评论资源的类型
    var type: String?
    
    /// 评论资源
    var sourceId = 0
    
    /// 评论内容
    var content: String?
    
    /// 发布时间
    var publishTime: String?

    /// 缓存高度
    var rowHeight: CGFloat = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override func setValue(value: AnyObject?, forKey key: String) {
        
        if key == "author" {
            author = JFCommentAuthor(dict: value as! [String : AnyObject])
            return
        } else if key == "extendsAuthor" {
            extendsAuthor = JFCommentExtendsAuthor(dict: value as! [String : AnyObject])
            return
        }
        
        return super.setValue(value, forKey: key)
    }
    
    /**
     加载评论列表
     
     - parameter page:      页码
     - parameter type:      评论资源类型
     - parameter source_id: 评论资源id
     - parameter finished:  完成回调
     */
    class func loadCommentList(page: Int, type: String, source_id: Int, finished: (comments: [JFComment]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "page" : page,
            "type" : type,
            "source_id" : source_id,
            "count" : 10,
            ]
        
        JFNetworkTools.shareNetworkTool.get(GET_COMMENT_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(comments: nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var comments = [JFComment]()
            
            for dict in data {
                let trends = JFComment(dict: dict)
                comments.append(trends)
            }
            
            finished(comments: comments)
        }
    }

    /**
     发布评论信息
     
     - parameter userId:   当前用户id
     - parameter type:     评论类型 video_info tweet
     - parameter sourceId: 类型资源id
     - parameter content:  评论内容
     - parameter pid:      回复评论id
     - parameter finished: 完成回调
     */
    class func publishComment(type: String, sourceId: Int, content: String, pid: Int = 0, finished: (success: Bool) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "type" : type,
            "source_id" : sourceId,
            "content" : content,
            "pid" : pid
            ]
        
        JFNetworkTools.shareNetworkTool.postWithToken(POST_COMMENT, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(success: false)
                return
            }
            
            finished(success: true)
        }
    }
}
