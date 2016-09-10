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
    func M3U8VideoDownloadFailWithVideoId(videoVid: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadParseFailWithVideoId(videoVid: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadFinishWithVideoId(videoVid: String, localPath path: String, videoInfoId: Int, index: Int)
    func M3U8VideoDownloadProgress(progress: CGFloat, withVideoVid videoVid: String, videoInfoId: Int, index: Int)
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
    func startDownload(videoInfoId: Int, needVideos: [[String : AnyObject]]) {
        
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
    func startDownloadVideo(videoInfoId: Int, index: Int, videoUrl: String) {
        
        JFVideo.parseVideoUrl(videoUrl) { (url) in
            guard let m3u8Url = url else {
                return
            }
            
            let videoDownload = SCM3U8VideoDownload(videoId: JFVideo.getVideoId(videoUrl), videoUrl: m3u8Url, videoInfoId: videoInfoId, index: index)
            videoDownload.delegate = self
            videoDownload.changeDownloadVideoState()
            self.videoDownloadQueue.append(videoDownload)
        }
        
    }
    
    /**
     取消下载
     
     - parameter videoUrl: 单个优酷视频的网页地址
     */
    func cancelDownloadVideo(videoUrl: String) {
        
        let videoId = JFVideo.getVideoId(videoUrl)
        
        var removeIndex = 0
        for (index, videoDownload) in videoDownloadQueue.enumerate() {
            if videoDownload.vid == videoId {
                removeIndex = index
                break
            }
        }
        
        // 取消下载
        let download = videoDownloadQueue[removeIndex]
        download.deleteDownloadVideo()
        videoDownloadQueue.removeAtIndex(removeIndex)
    }
    
}

// MARK: - SCM3U8VideoDownloadDelegate
extension JFDownloadManager: SCM3U8VideoDownloadDelegate {
    
    func M3U8VideoDownloadFailWithVideoId(videoId: String!, videoInfoId: Int, index: Int) {
        print("下载失败 \(videoId)")
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadFailWithVideoId(videoId, videoInfoId: videoInfoId, index: index)
    }
    
    func M3U8VideoDownloadParseFailWithVideoId(videoId: String!, videoInfoId: Int, index: Int) {
        print("解析视频失败 \(videoId)")
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadParseFailWithVideoId(videoId, videoInfoId: videoInfoId, index: index)
    }
    
    func M3U8VideoDownloadFinishWithVideoId(videoId: String!, localPath path: String!, videoInfoId: Int, index: Int) {
        print("下载完成 \(videoId) \(path)")
        JFDALManager.shareManager.insertVideo(videoId)
        removeDownloadManager(videoId)
        delegate?.M3U8VideoDownloadFinishWithVideoId(videoId, localPath: path, videoInfoId: videoInfoId, index: index)
    }
    
    func M3U8VideoDownloadProgress(progress: CGFloat, withVideoId videoId: String!, videoInfoId: Int, index: Int) {
        delegate?.M3U8VideoDownloadProgress(progress, withVideoVid: videoId, videoInfoId: videoInfoId, index: index)
    }
    
    /**
     移除下载对象
     
     - parameter videoId: 视频vid
     */
    func removeDownloadManager(videoId: String) {
        
        var removeIndex = 0
        for (index, videoDownload) in videoDownloadQueue.enumerate() {
            if videoDownload.vid == videoId {
                removeIndex = index
                break
            }
        }
        
        // 移除下载对象
        videoDownloadQueue.removeAtIndex(removeIndex)
        
    }
    
}