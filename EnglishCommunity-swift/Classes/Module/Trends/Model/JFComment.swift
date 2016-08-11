//
//  JFComment.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFComment: NSObject {
    
    /// 评论id
    var id = 0
    
    /// 评论资源的类型
    var type: String?
    
    /// 评论资源
    var source_id = 0
    
    /// 评论用户id
    var user_id = 0
    
    /// 评论用户头像
    var user_nickname: String?
    
    /// 评论用户头像
    var user_avatar: String?
    
    /// 被回复用户id
    var puser_id = 0
    
    /// 被回复用户头像
    var puser_nickname: String?
    
    /// 被回复用户头像
    var puser_avatar: String?
    
    /// 评论内容
    var content: String?
    
    /// 回复的评论id
    var pid = 0
    
    /// 发布时间
    var created_at: String?
    
    /// 发布时间
    var publishTime: String {
        return created_at!.stringToTimeStamp().timeStampToDate().dateToDescription()
    }

    /// 缓存高度
    var rowHeight: CGFloat = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
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
            
            guard let result = result where success == true && result["status"] == "success" else {
                print(success, error)
                finished(comments: nil)
                return
            }
            
            let data = result["data"]["data"].arrayObject as! [[String : AnyObject]]
            var comments = [JFComment]()
            
            for dict in data {
                let trends = JFComment(dict: dict)
                comments.append(trends)
            }
            
            finished(comments: comments)
        }
    }

    
}
