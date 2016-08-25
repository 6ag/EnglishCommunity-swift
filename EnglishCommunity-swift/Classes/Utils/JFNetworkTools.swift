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
                // print(json)
                finished(success: true, result: json, error: nil)
            } else {
                JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
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
                // print(json)
                finished(success: true, result: json, error: nil)
            } else {
                JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
                finished(success: false, result: nil, error: response.result.error)
            }
        }
    }
    
    /**
     带token的GET请求
     
     - parameter APIString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func getWithToken(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        guard let token = JFAccountModel.shareAccount()?.token else {
            return
        }
        
        print("\(BASE_URL)\(APIString)")
        Alamofire.request(.GET, "\(BASE_URL)\(APIString)", parameters: parameters, encoding: ParameterEncoding.URL, headers: ["Authorization" : "Bearer \(token)"]).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                if json["code"].intValue >= 4000 {
                    JFAccountModel.logout()
                }
                // print(json)
                finished(success: true, result: json, error: nil)
            } else {
                JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
                finished(success: false, result: nil, error: response.result.error)
            }
        }
        
    }
    
    /**
     带token的POST请求
     
     - parameter APIString:  urlString
     - parameter parameters: 参数
     - parameter finished:   完成回调
     */
    func postWithToken(APIString: String, parameters: [String : AnyObject]?, finished: NetworkFinished) {
        
        guard let token = JFAccountModel.shareAccount()?.token else {
            return
        }
        
        print("\(BASE_URL)\(APIString)")
        Alamofire.request(.POST, "\(BASE_URL)\(APIString)", parameters: parameters, encoding: ParameterEncoding.JSON, headers: ["Authorization" : "Bearer \(token)"]).responseJSON { (response) -> Void in
            
            if let data = response.data {
                let json = JSON(data: data)
                if json["code"].intValue >= 4000 {
                    JFAccountModel.logout()
                }
                // print(json)
                finished(success: true, result: json, error: nil)
            } else {
                JFProgressHUD.showInfoWithStatus("您的网络不给力哦")
                finished(success: false, result: nil, error: response.result.error)
            }
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
    func sendTweets(text: String, images: [UIImage]?, atUsers: [[String : AnyObject]]?, finished: NetworkFinished) {
        
        var parameters = [String : AnyObject]()
        parameters["user_id"] = JFAccountModel.shareAccount()!.id;
        parameters["content"] = text;
        
        // 图片
        if let images = images where images.count > 0 {
            var imageBase64s = [String]()
            for image in images {
                let imageData = UIImageJPEGRepresentation(image, 1)!
                let imageBase64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
                imageBase64s.append(imageBase64)
            }
            
            if let json = objectToJson(imageBase64s) {
                parameters["photos"] = json
            }
        }
        
        // 被at用户
        if let atUsers = atUsers where atUsers.count > 0 {
            if let json = objectToJson(atUsers) {
                parameters["atUsers"] = json
            }
        }
        
        postWithToken(POST_TWEETS, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除赞记录
     
     - parameter type:      赞的类型 video_info / tweet
     - parameter sourceID:  视频信息或动弹的id
     - parameter finished:  完成回调
     */
    func addOrCancelLikeRecord(type: String, sourceID: Int, finished: NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "type" : type,
            "source_id" : sourceID
        ]
        
        postWithToken(ADD_OR_CANCEL_LIKE_RECORD, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除收藏
     
     - parameter VideoInfoId: 视频信息id
     - parameter finished:    完成回调
     */
    func addOrCancelCollection(videoInfoId: Int, finished: NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "video_info_id" : videoInfoId
        ]
        
        postWithToken(ADD_OR_CANCEL_COLLECTION, parameters: parameters, finished: finished)
    }
    
    /**
     添加或删除朋友
     
     - parameter relationUserId: 要发生关系用户的id
     - parameter finished:       完成回调
     */
    func addOrCancelFriend(relationUserId: Int, finished: NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "user_id" : JFAccountModel.shareAccount()!.id,
            "relation_user_id" : relationUserId
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
    func postFeedback(contact: String, content: String, finished: NetworkFinished) {
        
        let parameters: [String : AnyObject] = [
            "contact" : contact,
            "content" : content
        ]
        
        post(POST_FEEDBACK, parameters: parameters, finished: finished)
    }
}

// MARK: - 辅助方法
extension JFNetworkTools {
    
    /**
     对象转json
     */
    private func objectToJson(object: AnyObject) -> NSString? {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted)
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        } catch {
            return nil
        }
    }
    
    /**
     获取当前网络状态
     
     - returns: 0未知 1WiFi 22G 33G 44G
     */
    func getCurrentNetworkState() -> Int {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.networkState
    }
}
