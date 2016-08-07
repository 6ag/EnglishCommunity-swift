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
    
    /// 视频简介
    var intro: String?
    
    /// 视频封面图
    var photo: String?
    
    /// 视频浏览量
    var view: Int = 0
    
    /// 视频所属分类的id
    var category_id: Int = 0
    
    /// 视频讲师
    var teacher: String?
    
    /// 视频是否被推荐 1：推荐 0：没推荐
    var recommend: Int = 0
    
    /// 视频类型 youku tudou 根据类型可以做一些视频解析的操作
    var type: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     加载视频信息列表
     
     - parameter page:        当前页码
     - parameter count:       每页数量
     - parameter category_id: 每页数量
     - parameter recommend:   是否是推荐
     - parameter finished:    数据回调
     */
    class func loadVideoInfoList(page: Int, count: Int, category_id: Int, recommend: Int, finished: (videoInfos: [JFVideoInfo]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "category_id" : category_id,
            "page" : page,
            "count" : count,
            "recommend" : recommend
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_VIDEO_INFOS_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                print(success, error)
                finished(videoInfos: nil)
                return
            }
            
            let data = result["data"]["data"].arrayObject as! [[String : AnyObject]]
            var videoInfos = [JFVideoInfo]()
            
            for dict in data {
                videoInfos.append(JFVideoInfo(dict: dict))
            }
            
            finished(videoInfos: videoInfos)
            
        }
    }
    
}
