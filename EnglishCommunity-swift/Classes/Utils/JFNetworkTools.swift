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
     可以带其他参数的图片上传方式
     
     - parameter APIString:  urlString
     - parameter image:      要上传的image对象
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func uploadPhoto(APIString: String, image: UIImage, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        print("\(BASE_URL)\(APIString)")
        Alamofire.upload(.POST, "\(BASE_URL)\(APIString)", multipartFormData: { multipartFormData in
            
            // 如果有参数则一起加入
            if let parameters = parameters {
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            }
            
            let imageData = UIImageJPEGRepresentation(image, 1)!
            multipartFormData.appendBodyPart(data: imageData, name: "photo")
            
            },encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if let data = response.data {
                            let json = JSON(data: data)
                            finished(success: true, result: json, error: nil)
                        } else {
                            finished(success: false, result: nil, error: response.result.error)
                        }
                    }
                case .Failure(_):
                    finished(success: false, result: nil, error: nil)
                }
        })
        
    }
}
