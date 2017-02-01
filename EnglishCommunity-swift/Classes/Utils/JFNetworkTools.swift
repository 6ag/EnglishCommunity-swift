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

/// 网络请求回调
typealias NetworkFinished = (_ success: Bool, _ result: JSON?, _ error: NSError?) -> ()

class JFNetworkTools: NSObject {
    
    /// 网络工具类单例
    static let shareNetworkTool = JFNetworkTools()
}

// MARK: - 基础请求方法
extension JFNetworkTools {
    
    /**
     GET请求
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func get(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    }
    
    /**
     POST请求
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func post(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .post, parameters: parameters, headers: nil).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    }
    
    /**
     带token的GET请求
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func getWithToken(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        guard let token = JFAccountModel.shareAccount()?.token else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: ["Authorization" : "Bearer \(token)"]).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    }
    
    /**
     带token的POST请求
     
     - parameter urlString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func postWithToken(_ urlString: String, parameters: [String : Any]?, finished: @escaping NetworkFinished) {
        
        guard let token = JFAccountModel.shareAccount()?.token else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(urlString, method: .post, parameters: parameters, headers: ["Authorization" : "Bearer \(token)"]).responseJSON { (response) in
            self.handle(response: response, finished: finished)
        }
    
    }
    
    /// 处理响应结果
    ///
    /// - Parameters:
    ///   - response: 响应对象
    ///   - finished: 完成回调
    fileprivate func handle(response: DataResponse<Any>, finished: @escaping NetworkFinished) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let value):
            log(value)
            let json = JSON(value)
            if json["code"].intValue >= 4000 {
                // token失效 退出登录
                JFAccountModel.logout()
                finished(false, json, nil)
            } else {
                finished(true, json, nil)
            }
        case .failure(let error):
            finished(false, nil, error as NSError?)
        }
        
    }
    
}

// MARK: - 抽取业务请求 - 需要token验证
extension JFNetworkTools {
    
    /**
     发布动弹
     
     - parameter APIString: urlString
     - parameter text:      文字内容
     - parameter images:    图片     [UIimage]?
     - parameter atUsers:   被at用户 [[id : AnyObject, nickname : AnyObject]]?
     - parameter finished:  完成回调
     */
    func sendTweets(_ text: String, images: [UIImage]?, atUsers: [[String : AnyObject]]?, finished: @escaping NetworkFinished) {
        
        var parameters = [String : AnyObject]()
        parameters["user_id"] = JFAccountModel.shareAccount()!.id as AnyObject?;
        parameters["content"] = text as AnyObject?;
        
        // 图片
        if let images = images, images.count > 0 {
            var imageBase64s = [String]()
            for image in images {
                let imageData = UIImageJPEGRepresentation(image, 1)!
                let imageBase64 = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                imageBase64s.append(imageBase64)
            }
            
            if let json = objectToJson(imageBase64s as AnyObject) {
                parameters["photos"] = json
            }
        }
        
        // 被at用户
        if let atUsers = atUsers, atUsers.count > 0 {
            if let json = objectToJson(atUsers as AnyObject) {
                parameters["atUsers"] = json
            }
        }
        
        print(parameters)
        postWithToken(POST_TWEETS, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除赞记录
     
     - parameter type:      赞的类型 video_info / tweet
     - parameter sourceID:  视频信息或动弹的id
     - parameter finished:  完成回调
     */
    func addOrCancelLikeRecord(_ type: String, sourceID: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "type" : type as AnyObject,
            "source_id" : sourceID as AnyObject
        ]
        
        postWithToken(ADD_OR_CANCEL_LIKE_RECORD, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除收藏
     
     - parameter VideoInfoId: 视频信息id
     - parameter finished:    完成回调
     */
    func addOrCancelCollection(_ videoInfoId: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "video_info_id" : videoInfoId as AnyObject
        ]
        
        postWithToken(ADD_OR_CANCEL_COLLECTION, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除朋友
     
     - parameter relationUserId: 要发生关系用户的id
     - parameter finished:       完成回调
     */
    func addOrCancelFriend(_ relationUserId: Int, finished: @escaping NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id as AnyObject,
            "relation_user_id" : relationUserId as AnyObject
        ]
        
        postWithToken(ADD_OR_CANCEL_FRIEND, parameters: parameters, finished: finished)
    }
    
}

// MARK: - 抽取业务请求 - 免验证
extension JFNetworkTools {
    
    /**
     提交反馈信息
     
     - parameter contact:  联系方式
     - parameter content:  反馈内容
     - parameter finished: 完成回调
     */
    func postFeedback(_ contact: String, content: String, finished: @escaping NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "contact" : contact as AnyObject,
            "content" : content as AnyObject
        ]
        
        post(POST_FEEDBACK, parameters: parameters, finished: finished)
    }
    
    /**
     获取播放节点
     
     - parameter finished: 完成回调
     */
    func getPlayNode(_ finished: @escaping NetworkFinished) {
        get(GET_PALY_NODE, parameters: nil, finished: finished)
    }
}

// MARK: - 辅助方法
extension JFNetworkTools {
    
    /**
     对象转json
     */
    fileprivate func objectToJson(_ object: AnyObject) -> NSString? {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        } catch {
            return nil
        }
    }
    
    /**
     获取当前网络状态
     
     - returns: 0未知 1WiFi 2WAN
     */
    func getCurrentNetworkState() -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.networkState
    }
}
