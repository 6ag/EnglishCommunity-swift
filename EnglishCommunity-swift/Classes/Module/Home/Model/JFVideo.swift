//
//  JFVideo.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFVideo: NSObject {
    
    /// 视频小节id
    var id: Int = 0
    
    /// 视频小节标题
    var title: String?
    
    /// 视频id
    var videoInfoId: Int = 0
    
    /// 视频小节的地址
    var videoUrl: String?
    
    /// 视频序号 - 第几小节
    var order: Int = 0
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     加载指定视频信息的视频播放列表
     
     - parameter video_info_id: 视频信息id
     */
    class func loadVideoList(video_info_id: Int, finished: (videos: [JFVideo]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "video_info_id" : video_info_id
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_VIDEO_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result where success == true && result["status"] == "success" else {
                print(success, error)
                finished(videos: nil)
                return
            }
            
            let data = result["result"].arrayObject as! [[String : AnyObject]]
            var videos = [JFVideo]()
            
            for dict in data {
                videos.append(JFVideo(dict: dict))
            }
            
            finished(videos: videos)
        }
    }
    
}
