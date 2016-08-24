//
//  JFDownloadDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Alamofire

class JFDownloadDetailViewController: UIViewController {

    // 下载文件的保存路径
    let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    
    // 用于停止下载时，保存已下载的部分
    var cancelledData: NSData?
    
    // 下载请求对象
    var downloadRequest: Request!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDownload("http://dldir1.qq.com/qqfile/qq/QQ7.9/16621/QQ7.9.exe")
        print(destination)
    }
    
    /**
     开始下载
     */
    func startDownload(url: String) {
        self.downloadRequest =  Alamofire.download(.GET, url, destination: destination)
        self.downloadRequest.progress(downloadProgress) // 下载进度
        self.downloadRequest.response(completionHandler: downloadResponse) // 下载停止响应
    }
    
    // 下载过程中改变进度条
    func downloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        
        let percent = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
        
        //进度条更新
        print("当前进度：\(percent * 100)%")
    }
    
    // 下载停止响应（不管成功或者失败）
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
        }
    }
    
    // 停止下载
    func stopBtnClick() {
        self.downloadRequest?.cancel()
    }
    
    // 继续下载
    func continueBtnClick() {
        if let cancelledData = self.cancelledData {
            self.downloadRequest = Alamofire.download(resumeData: cancelledData, destination: destination)
            self.downloadRequest.progress(downloadProgress) // 下载进度
            self.downloadRequest.response(completionHandler: downloadResponse) // 下载停止响应
        }
    }

}
