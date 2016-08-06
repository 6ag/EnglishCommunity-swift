//
//  Api.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import Foundation

/// 基URL
let BASE_URL = "http://www.english.com/"

/// 获取所有分类信息
let GET_CATEGORY = "api/category"

/**
 根据分类id查询视频信息列表
 
 - parameter categoryID: 分类id
 
 - returns: 接口
 */
func GET_VIDEO_INFO_LIST(categoryID: Int) -> String {
    return "api/category/\(categoryID)/video"
}

/**
 根据分类id查询视频信息列表
 
 - parameter videoID: 视频id
 
 - returns: 接口
 */
func GET_VIDEO_LIST(videoID: Int) -> String {
    return "api/video/\(videoID)"
}
