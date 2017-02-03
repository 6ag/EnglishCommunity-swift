//
//  JFDownloadManager.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Alamofire

protocol JFDownloadManagerDelegate: NSObjectProtocol {
    func M3U8VideoDownloadFailWithVideoId(_ videoVid: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadParseFailWithVideoId(_ videoVid: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadFinishWithVideoId(_ videoVid: String, localPath path: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadProgress(_ progress: CGFloat, withVideoVid videoVid: String, videoInfoId: Int, index: Int)
}

class JFDownloadManager: NSObject {
    
    static let shareManager = JFDownloadManager()
    weak var delegate: JFDownloadManagerDelegate?
    
    // 所有视频下载的队列
    var videoDownloadQueue = [SCM3U8VideoDownload]()
    
    /**
     开始下载视频
     
     - parameter videoInfoId: 视频信息id
     - parameter videos:      视频模型数组
     */
    func startDownload(_ videoInfoId: Int, needVideos: [[String : AnyObject]]) {
        
        for needVideo in needVideos {
            let index = needVideo["index"] as! Int
            let video = needVideo["video"] as! JFVideo
            startDownloadVideo(videoInfoId, index: index, videoUrl: video.videoUrl!)
        }
    }
    
    /**
     开始下载视频
     
     - parameter videoUrl: 单个优酷视频的网页地址
     */
    func startDownloadVideo(_ videoInfoId: Int, index: Int, videoUrl: String) {
        
        JFVideo.parseVideoUrl(videoUrl) { (url) in
            guard let m3u8Url = url else {
                return
            }
            
            let videoDownload = SCM3U8VideoDownload(videoId: JFVideo.getVideoId(videoUrl), videoUrl: m3u8Url, videoInfoId: videoInfoId, index: index)
            videoDownload?.delegate = self
            videoDownload?.changeVideoState()
            self.videoDownloadQueue.append(videoDownload!)
        }
        
    }
    
    /**
     取消下载
     
     - parameter videoUrl: 单个优酷视频的网页地址
     */
    func cancelDownloadVideo(_ videoUrl: String) {
        
        let videoId = JFVideo.getVideoId(videoUrl)
        
        var removeIndex = 0
        for (index, videoDownload) in videoDownloadQueue.enumerated() {
            if videoDownload.vid == videoId {
                removeIndex = index
                break
            }
        }
        
        // 取消下载
        let download = videoDownloadQueue[removeIndex]
        download.deleteVideo()
        videoDownloadQueue.remove(at: removeIndex)
    }
    
}

// MARK: - SCM3U8VideoDownloadDelegate
extension JFDownloadManager: SCM3U8VideoDownloadDelegate {
    
    func m3U8VideoDownloadFail(withVideoId videoId: String!, videoInfoId: Int, index: Int) {
        log("下载失败 \(videoId)")
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadFailWithVideoId(videoId, videoInfoId: videoInfoId, index: index)
    }
    
    func m3U8VideoDownloadParseFail(withVideoId videoId: String!, videoInfoId: Int, index: Int) {
        log("解析视频失败 \(videoId)")
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadParseFailWithVideoId(videoId, videoInfoId: videoInfoId, index: index)
    }
    
    func m3U8VideoDownloadFinish(withVideoId videoId: String!, localPath path: String!, videoInfoId: Int, index: Int) {
        log("下载完成 \(videoId) \(path)")
        JFDALManager.shareManager.insertVideo(videoId)
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadFinishWithVideoId(videoId, localPath: path, videoInfoId: videoInfoId, index: index)
    }
    
    func m3U8VideoDownloadProgress(_ progress: CGFloat, withVideoId videoId: String!, videoInfoId: Int, index: Int) {
        delegate?.M3U8VideoDownloadProgress(progress, withVideoVid: videoId, videoInfoId: videoInfoId, index: index)
    }
    
    /**
     移除下载对象
     
     - parameter videoId: 视频vid
     */
    func removeDownloadManager(_ videoId: String) {
        
        var removeIndex = 0
        for (index, videoDownload) in videoDownloadQueue.enumerated() {
            if videoDownload.vid == videoId {
                removeIndex = index
                break
            }
        }
        
        // 移除下载对象
        videoDownloadQueue.remove(at: removeIndex)
        
    }
    
}
