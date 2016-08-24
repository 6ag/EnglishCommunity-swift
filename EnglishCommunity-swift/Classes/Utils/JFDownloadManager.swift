//
//  JFDownloadManager.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Alamofire

class JFDownloadManager: NSObject {
    
    static let shareManager = JFDownloadManager()
    var downloadQueues = [[JFDownloadQueue]]()
    var videoInfo: JFVideoInfo?
    
    /**
     开始下载视频
     
     - parameter videoInfo: 视频信息模型
     - parameter videos:    视频模型数组
     */
    func startDownloadVideo(videoInfo: JFVideoInfo, videos: [JFVideo]) {
        
        for video in videos {
            getVideoDownloadList(video.videoUrl!)
        }
        self.videoInfo = videoInfo
    }
    
    /**
     获取单个视频的分段下载列表
     
     - parameter videoUrl: 单个优酷视频的网页地址
     */
    func getVideoDownloadList(videoUrl: String) {
        
        JFVideo.getVideoDownloadList(videoUrl) { (urls) in
            guard let urls = urls else {
                return
            }
            
            // 一节视频
            var downloadQueues = [JFDownloadQueue]()
            for url in urls {
                downloadQueues.append(JFDownloadQueue().startDownload(url))
            }
            self.downloadQueues.append(downloadQueues)
        }
    }
    
}