
//
//  JFVideoInfo.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFVideoInfo: NSObject {
    
    /// 视频id
    var id: Int = 0
    
    /// 视频标题
    var title: String?
    
    /// 视频封面图
    var cover: String?
    
    /// 视频浏览量
    var view: Int = 0
    
    /// 视频讲师
    var teacherName: String?
    
    /// 视频类型 youku tudou 根据类型可以做一些视频解析的操作
    var videoType: String?
    
    /// 视频是否被推荐 1：推荐 0：没推荐
    var recommended: Int = 0
    
    /// 视频节数
    var videoCount = 0
    
    /// 评论数量
    var commentCount = 0
    
    /// 收藏数量
    var collectionCount = 0
    
    /// 是否已经收藏 0未收藏 1收藏
    var collected = 0
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /**
     搜索视频信息列表
     
     - parameter keyword:  搜索关键词
     - parameter page:     页码
     - parameter count:    每页数量
     - parameter finished: 完成回调
     */
    class func searchVideoInfoList(_ keyword: String, page: Int, count: Int = 10, finished: @escaping (_ videoInfos: [JFVideoInfo]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "keyword" : keyword as AnyObject,
            "page" : page as AnyObject,
            "count" : count as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.get(SEARCH_VIDEO_INFO_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result else {
                finished(nil)
                return
            }
            
            if result["status"] == "success" {
                let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
                var videoInfos = [JFVideoInfo]()
                for dict in data {
                    videoInfos.append(JFVideoInfo(dict: dict))
                }
                finished(videoInfos)
            } else {
                JFProgressHUD.showInfoWithStatus(result["message"].stringValue)
                finished(nil)
            }
            
        }
    }
    
    /**
     加载视频信息列表
     
     - parameter page:        当前页码
     - parameter count:       每页数量
     - parameter category_id: 分类id
     - parameter recommend:   是否是推荐
     - parameter finished:    数据回调
     */
    class func loadVideoInfoList(_ page: Int, count: Int, category_id: Int, recommend: Int, finished: @escaping (_ videoInfos: [JFVideoInfo]?) -> ()) {
        
        // 先去本地获取推荐数据
        if recommend == 1 {
            if let json = getJson(BANNER_JSON_PATH) {
                let data = json["result"]["data"].arrayObject as! [[String : AnyObject]]
                var videoInfos = [JFVideoInfo]()
                
                for dict in data {
                    videoInfos.append(JFVideoInfo(dict: dict))
                }
                
                finished(videoInfos)
                return
            }
        }
        
        let parameters: [String : AnyObject] = [
            "category_id" : category_id as AnyObject,
            "page" : page as AnyObject,
            "count" : count as AnyObject,
            "recommend" : recommend as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_VIDEO_INFOS_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            // 缓存本地数据
            if recommend == 1 {
                saveJson(result, jsonPath: BANNER_JSON_PATH)
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var videoInfos = [JFVideoInfo]()
            
            for dict in data {
                videoInfos.append(JFVideoInfo(dict: dict))
            }
            
            finished(videoInfos)
            
        }
    }
    
    /**
     加载视频信息详情
     
     - parameter videoInfoId: 视频信息id
     - parameter finished:    完成回调
     */
    class func loadVideoInfoDetail(_ videoInfoId: Int, finished: @escaping (_ videoInfo: JFVideoInfo?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()?.id as AnyObject? ?? 0 as AnyObject,
            "video_info_id" : videoInfoId as AnyObject,
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_VIDEO_INFO_DETAIL, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            let dict = result["result"].dictionaryObject!
            finished(JFVideoInfo(dict: dict))
            
        }
    }
    
    
    /**
     加载收藏信息列表
     
     - parameter user_id:  当前用户id
     - parameter page:     当前页码
     - parameter count:    每页数量
     - parameter finished: 数据回调
     */
    class func loadCollectionVideoInfoList(_ page: Int, count: Int, finished: @escaping (_ videoInfos: [JFVideoInfo]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "page" : page as AnyObject,
            "count" : count as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_COLLECTION_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var videoInfos = [JFVideoInfo]()
            
            for dict in data {
                videoInfos.append(JFVideoInfo(dict: dict))
            }
            
            finished(videoInfos)
            
        }
    }
    
}
