//
//  JFVideoCategory.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SwiftyJSON

class JFVideoCategory: NSObject {

    /// 分类id
    var id: Int = 0
    
    /// 分类名称
    var name: String?
    
    /// 分类别名
    var alias: String?
    
    /// 分类浏览量
    var view: Int = 0
    
    /// 分类下的视频信息数据
    var videoInfos: [JFVideoInfo]?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    override func setValue(value: AnyObject?, forKey key: String) {
        
        if key == "videoInfoList" {
            if let data = value as? [[String : AnyObject]] {
                var videoInfos = [JFVideoInfo]()
                for dict in data {
                    videoInfos.append(JFVideoInfo(dict: dict))
                }
                self.videoInfos = videoInfos
            }
            
        }
        
        super.setValue(value, forKey: key)
    }
    
    /**
     查询所有分类信息 - 首页
     
     - parameter have_data: 是否让返回结果带分类下的视频信息数据
     - parameter count:     返回结果带分类下的视频信息数据条数 默认4条
     - parameter finished:  数据回调
     */
    class func loadAllCategories(have_data: Int, count: Int, finished: (videoCategories: [JFVideoCategory]?) -> ()) {
        
        // 先去缓存中获取
        if let json = getJson(CATEGORIES_JSON_PATH) {
            let data = json["result"].arrayObject as! [[String : AnyObject]]
            var videoCategories = [JFVideoCategory]()
            
            for dict in data {
                videoCategories.append(JFVideoCategory(dict: dict))
            }
            
            finished(videoCategories: videoCategories)
            return
        }
        
        let parameters: [String : AnyObject] = [
            "have_data" : 1,
            "count" : 4
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_ALL_CATEGORIES, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                print(success, error, parameters)
                finished(videoCategories: nil)
                return
            }
            
            // 新数据要先缓存再返回
            saveJson(result, jsonPath: CATEGORIES_JSON_PATH)
            
            let data = result["result"].arrayObject as! [[String : AnyObject]]
            var videoCategories = [JFVideoCategory]()
            
            for dict in data {
                videoCategories.append(JFVideoCategory(dict: dict))
            }
            
            finished(videoCategories: videoCategories)
        }
    }
    
    
    
}
