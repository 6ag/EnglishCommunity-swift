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
    
    /// 学员数量 - 暂时没用 后面可以改成收藏数量
    var joinCount = 0
    
    /// 视频节数
    var videoCount = 0
    
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
                print(success, error, parameters)
                finished(videoInfos: nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var videoInfos = [JFVideoInfo]()
            
            for dict in data {
                videoInfos.append(JFVideoInfo(dict: dict))
            }
            
            finished(videoInfos: videoInfos)
            
        }
    }
    
}
