//
//  JFTrends.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFTrends: NSObject {
    
    /// 动弹id
    var id = 0
    
    /// 作者id
    var user_id = 0
    
    /// 作者昵称
    var user_nickname: String?
    
    /// 作者头像
    var user_avatar: String?
    
    /// 动弹内容
    var content: String?
    
    /// 缩略图
    var small_photo: String?
    
    /// 大图
    var photo: String?
    
    /// 浏览量
    var view = 0
    
    /// 发布时间
    var created_at: String?
    
    /// 评论数量
    var comment_count = 0
    
    /// 赞数量
    var favorite_count = 0
    
    /// 当前浏览者是否已经赞
    var is_favorite = 0
    
    /// 发布时间
    var publishTime: String {
        return created_at!.stringToTimeStamp().timeStampToDate().dateToDescription()
    }
    
    /// 缓存行高
    var rowHeight: CGFloat = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     缓存大图
     
     - parameter bigpath: 大图路径
     */
    private class func trendsImageCache(imagePath: String?) {
        
        guard let imagePath = imagePath else {
//            print("没有图片无需缓存")
            return
        }
        
        if !YYImageCache.sharedCache().containsImageForKey("\(BASE_URL)/\(imagePath)") {
            YYWebImageManager(cache: YYImageCache.sharedCache(), queue: NSOperationQueue()).requestImageWithURL(NSURL(string: "\(BASE_URL)/\(imagePath)")!, options: YYWebImageOptions.UseNSURLCache, progress: { (_, _) in
                }, transform: { (image, url) -> UIImage? in
                    return image
                }, completion: { (image, url, type, stage, error) in
            })
//            print("\(imagePath) 首次缓存")
        }
    }
    
    /**
     加载动弹列表
     
     - parameter type:     加载类型
     - parameter page:     页码
     - parameter user_id:  浏览者id
     - parameter finished: 完成回调
     */
    class func loadTrendsList(type: String, page: Int, user_id: Int, finished: (trendsArray: [JFTrends]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "type" : type,
            "page" : page,
            "user_id" : user_id,
            "count" : 20,
            ]
        
        JFNetworkTools.shareNetworkTool.get(GET_TRENDS_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                print(success, error)
                finished(trendsArray: nil)
                return
            }
            
            let data = result["data"]["data"].arrayObject as! [[String : AnyObject]]
            var trendsArray = [JFTrends]()
            
            for dict in data {
                let trends = JFTrends(dict: dict)
                trendsArray.append(trends)
                
                // 缓存图片
                self.trendsImageCache(trends.small_photo)
                self.trendsImageCache(trends.photo)
            }
            
            finished(trendsArray: trendsArray)
        }
    }
    
}

