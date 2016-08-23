//
//  JFTrends.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

/// 动弹作者
class JFTweetAuthor: NSObject {
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

/// 动弹图片模型
class JFTweetImage: NSObject {
    
    /// 正常尺寸图片
    var href: String?
    
    /// 缩略图尺寸图片
    var thumb: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}

/// 动弹被at的用户模型
class JFTweetAtUser: NSObject {
    
    /// 用户id
    var id: Int = 0
    
    /// 昵称
    var nickname: String?
    
    /// at的顺序
    var sequence = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}

/// 动弹模型
class JFTweet: NSObject {
    
    /// 作者
    var author: JFTweetAuthor?
    
    /// 动弹图片模型数组
    var images: [JFTweetImage]?
    
    /// 被at的用户模型数组
    var atUsers: [JFTweetAtUser]?
    
    /// 动弹id
    var id = 0
    
    /// app客户端 0：iOS 1：Android
    var appClient = 0
    
    /// 动弹内容
    var content: String?
    
    /// 浏览量
    var view = 0
    
    /// 评论数量
    var commentCount = 0
    
    /// 赞数量
    var likeCount = 0
    
    /// 当前浏览者是否已经赞
    var liked = 0
    
    /// 发布时间 - 时间戳
    var publishTime: String?
    
    /// 缓存行高
    var rowHeight: CGFloat = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override func setValue(value: AnyObject?, forKey key: String) {
        
        if key == "author" {
            self.author = JFTweetAuthor(dict: value as! [String : AnyObject])
            return
        } else if key == "images" {
            let data = value as! [[String : AnyObject]]
            var images = [JFTweetImage]()
            for dict in data {
                images.append(JFTweetImage(dict: dict))
            }
            self.images = images
            return
        } else if key == "atUsers" {
            let data = value as! [[String : AnyObject]]
            var atUsers = [JFTweetAtUser]()
            for dict in data {
                atUsers.append(JFTweetAtUser(dict: dict))
            }
            self.atUsers = atUsers
            return
        }
        
        return super.setValue(value, forKey: key)
    }
    
    /**
     缓存配图
     
     - parameter tweetsArray: 动弹模型数组
     - parameter finished:    完成回调
     */
    class func cacheWebImage(tweets: [JFTweet]?, finished: (tweets: [JFTweet]?) -> ()) {
        
        guard let tweets = tweets else {
            finished(tweets: nil)
            return
        }
        
        let group = dispatch_group_create()
        
        for tweet in tweets {
            let count = tweet.images?.count ?? 0
            if count == 0 {
                continue
            }
            
            // 判断是否有图片需要下载
            if let images = tweet.images where tweet.images?.count == 1 {
                
                dispatch_group_enter(group)
                
                let urlString = images.first!.thumb!
                
                if !YYImageCache.sharedCache().containsImageForKey(urlString) {
                    YYWebImageManager(cache: YYImageCache.sharedCache(), queue: NSOperationQueue()).requestImageWithURL(NSURL(string: urlString)!, options: YYWebImageOptions.UseNSURLCache, progress: { (_, _) in
                        }, transform: { (image, url) -> UIImage? in
                            return image
                        }, completion: { (image, url, type, stage, error) in
                            dispatch_group_leave(group)
                    })
                } else {
                    dispatch_group_leave(group)
                }
                
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            finished(tweets: tweets)
        }
    }
    
    
    /**
     加载动弹列表
     
     - parameter type:     加载类型
     - parameter page:     页码
     - parameter finished: 完成回调
     */
    class func loadTrendsList(type: String, page: Int, finished: (tweets: [JFTweet]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "type" : type,
            "page" : page,
            "user_id" : JFAccountModel.shareAccount()?.id ?? 0,
            "count" : 20,
            ]
        
        JFNetworkTools.shareNetworkTool.get(GET_TWEETS_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                print(success, error, parameters)
                finished(tweets: nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var tweets = [JFTweet]()
            
            for dict in data {
                let tweet = JFTweet(dict: dict)
                tweets.append(tweet)
            }
            
            cacheWebImage(tweets, finished: finished)
        }
    }
    
    /**
     加载动弹详情
     
     - parameter tweet_id: 动弹id
     - parameter finished: 完成回调
     */
    class func loadTrendsDetail(tweet_id: Int, finished: (tweet: JFTweet?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "tweet_id" : tweet_id,
            "user_id" : JFAccountModel.shareAccount()?.id ?? 0
            ]
        
        JFNetworkTools.shareNetworkTool.get(GET_TWEETS_DETAIL, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(tweet: nil)
                return
            }
            
            let dict = result["result"].dictionaryObject!
            finished(tweet: JFTweet(dict: dict))
        }
    }
    
}

