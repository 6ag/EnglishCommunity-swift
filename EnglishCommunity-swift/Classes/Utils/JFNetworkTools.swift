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
        
        print("\(BASE_URL)\(APIString)", parameters)
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
}
