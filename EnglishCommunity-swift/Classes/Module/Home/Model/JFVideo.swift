//
//  JFVideo.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

/**
 视频的状态
 
 - AlreadyDownload: 已经下载
 - NoDownload:      没有下载
 - Downloading:     正在下载
 */
enum VideoState {
    case alreadyDownload
    case noDownload
    case downloading
}

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
    
    /// 下载列表是否已经选中 - 下载列表会用到
    var downloadListSelected: Bool = false
    
    /// 视频列表是否选中状态
    var videoListSelected: Bool = false
    
    /// 下载进度
    var progress: CGFloat = 0.0
    
    /// 视频的状态
    var state = VideoState.noDownload
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /**
     加载指定视频信息的视频播放列表
     
     - parameter video_info_id: 视频信息id
     */
    class func loadVideoList(_ video_info_id: Int, finished: @escaping (_ videos: [JFVideo]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "video_info_id" : video_info_id as AnyObject
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_VIDEO_LIST, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            let data = result["result"].arrayObject as! [[String : AnyObject]]
            var videos = [JFVideo]()
            
            for dict in data {
                let video = JFVideo(dict: dict)
                JFDALManager.shareManager.getVideo(JFVideo.getVideoId(video.videoUrl!), finished: { (have) in
                    video.state = have ? VideoState.alreadyDownload : VideoState.noDownload
                })
                videos.append(video)
            }
            
            // 默认选中第一个
            videos[0].videoListSelected = true
            finished(videos)
        }
    }
    
    /**
     解析优酷真实播放地址m3u8
     
     - parameter youKuUrl: 优酷网页地址
     - parameter finished: 完成回调
     */
    class func parseVideoUrl(_ youKuUrl: String, finished: @escaping (_ url: String?) -> ()) {
        
        JFNetworkTools.shareNetworkTool.get(PARSE_YOUKU_VIDEO, parameters: ["url" : youKuUrl]) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            finished(result["result"]["videoUrl"].stringValue)
        }
        
    }
    
    /**
     获取视频的id
     
     - parameter videoUrl: 视频网址
     
     - returns: id
     */
    class func getVideoId(_ videoUrl: String) -> String {
        // 获取视频id
        var id = (videoUrl as NSString).replacingOccurrences(of: "http://v.youku.com/v_show/id_", with: "")
        id = (id as NSString).replacingOccurrences(of: ".html", with: "")
        return id
    }
    
    /**
     获取优酷真实下载视频分段地址
     
     - parameter youKuUrl: 优酷网页地址
     - parameter finished: 完成回调
     */
    class func getVideoDownloadList(_ youKuUrl: String, finished: @escaping (_ urls: [String]?) -> ()) {
        
        JFNetworkTools.shareNetworkTool.getWithToken(GET_VIDEO_DOWNLOAD_LIST, parameters: ["url" : youKuUrl]) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            // 默认清晰度的视频片段地址列表
            guard let normalData = result["result"]["normal"]["data"].arrayObject as? [String] else {
                return
            }
            
            finished(normalData)
        }
        
    }
    
    
    
}
