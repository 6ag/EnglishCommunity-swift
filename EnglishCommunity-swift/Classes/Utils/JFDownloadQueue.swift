//
//  JFDownloadQueue.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Alamofire

protocol JFDownloadQueueDelegate: NSObjectProtocol {
    
    /**
     下载成功后响应结果
     
     - parameter local: 回调合并后的本地视频地址
     */
    func downloadComplete(local: String)
}

class JFDownloadQueue: NSObject {
    
    weak var delegate: JFDownloadQueueDelegate?
    
    // 下载文件的保存路径
    let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    
    // 用于停止下载时，保存已下载的部分
    var cancelledData: NSData?
    
    // 下载请求对象
    var downloadRequest: Request!
    
    /**
     开始下载
     */
    func startDownload(url: String) -> Self {
        self.downloadRequest =  Alamofire.download(.GET, url, destination: destination)
        self.downloadRequest.progress(downloadProgress)
        self.downloadRequest.response(completionHandler: downloadResponse)
        print(destination, url)
        return self
    }
    
    /**
     停止下载
     */
    func stopDownload() -> Self {
        self.downloadRequest?.cancel()
        return self
    }
    
    /**
     继续下载
     */
    func continueDownload() -> Self {
        if let cancelledData = self.cancelledData {
            self.downloadRequest = Alamofire.download(resumeData: cancelledData, destination: destination)
            self.downloadRequest.progress(downloadProgress)
            self.downloadRequest.response(completionHandler: downloadResponse)
        }
        return self
    }
    
    /**
     下载过程中改变进度条
     */
    func downloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
        
        //进度条更新
        print("当前进度：\(percent * 100)%")
    }
    
    /**
     下载结束
     */
    func downloadResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error:NSError?) {
        
        if let error = error {
            if error.code == NSURLErrorCancelled {
                // 意外终止的话，把已下载的数据储存起来
                self.cancelledData = data
            } else {
                print("Failed to download file: \(response) \(error)")
            }
        } else {
            print("Successfully downloaded file: \(response)")
            
            // 合并视频
            delegate?.downloadComplete("test")
        }
    }

}
