//
//  JFNetworkToolss.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/30.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias NetworkFinished = (success: Bool, result: JSON?, error: NSError?) -> ()

class JFNetworkTools: NSObject {
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTools()
}

// MARK: - 基础请求方法
extension JFNetworkTools {
    
    /**
     GET请求
     
     - parameter APIString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func get(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        print("\(BASE_URL)\(APIString)")
        Alamofire.request(.GET, "\(BASE_URL)\(APIString)", parameters: parameters).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                finished(success: true, result: json, error: nil)
            } else {
                finished(success: false, result: nil, error: response.result.error)
            }
        }
        
    }
    
    /**
     POST请求
     
     - parameter APIString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        print("\(BASE_URL)\(APIString)")
        Alamofire.request(.POST, "\(BASE_URL)\(APIString)", parameters: parameters).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                finished(success: true, result: json, error: nil)
            } else {
                finished(success: false, result: nil, error: response.result.error)
            }
        }
    }
    
    /**
     发布动弹
     
     - parameter APIString: urlString
     - parameter userId:    用户id
     - parameter text:      文字内容
     - parameter images:    图片
     - parameter finished:  完成回调
     */
    func sendTweets(APIString: String, userId: Int, text: String, images: [UIImage]?, finished: NetworkFinished) {
        
        var parameters = [String : AnyObject]()
        parameters["user_id"] = userId;
        parameters["content"] = text;
        
        if let images = images {
            var imageBase64s = [String]()
            for image in images {
                let imageData = UIImageJPEGRepresentation(image, 1)!
                let imageBase64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
//                imageBase64 = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, imageBase64, nil, ":/?@!$&'()*+,;=", CFStringBuiltInEncodings.UTF8.rawValue) as String
                imageBase64s.append(imageBase64)
            }
            parameters["photos"] = imageBase64s
        }
        
        // 发送请求
        post(APIString, parameters: parameters, finished: finished)
    }
    
}
