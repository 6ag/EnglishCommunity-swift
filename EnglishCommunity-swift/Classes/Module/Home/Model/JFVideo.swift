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
    
    /// 是否已经选中 - 下载列表会用到
    var selected: Bool = false
    
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
            
            guard let result = result where result["status"] == "success" else {
                print(success, error, parameters)
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
    
    /**
     解析优酷真实播放地址m3u8
     
     - parameter youKuUrl: 优酷网页地址
     - parameter finished: 完成回调
     */
    class func parseVideoUrl(youKuUrl: String, finished: (url: String?) -> ()) {
        
        JFNetworkTools.shareNetworkTool.get(PARSE_YOUKU_VIDEO, parameters: ["url" : youKuUrl]) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(url: nil)
                return
            }
            finished(url: result["result"]["videoUrl"].stringValue)
        }
        
    }
    
    /**
     获取优酷真实下载视频分段地址
     
     - parameter youKuUrl: 优酷网页地址
     - parameter finished: 完成回调
     */
    class func getVideoDownloadList(youKuUrl: String, finished: (urls: [String]?) -> ()) {
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_VIDEO_DOWNLOAD_LIST, parameters: ["url" : youKuUrl]) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(urls: nil)
                return
            }
            
            // 默认清晰度的视频片段地址列表
            guard let normalData = result["result"]["normal"]["data"].arrayObject as? [String] else {
                return
            }
            
            finished(urls: normalData)
        }
        
    }
    
    
    
}
