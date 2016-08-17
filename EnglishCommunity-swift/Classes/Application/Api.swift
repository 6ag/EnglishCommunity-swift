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

/// 发送手机验证码
let SEND_CODE = "api/auth/seedCode.api"

/// 注册
let REGISTER = "api/auth/register.api"

/// 登录
let LOGIN = "api/auth/login.api"

/// 修改用户密码
let MODIFY_USER_PASSWORD = "api/auth/modifyUserPassword.api"

/// 获取所有分类信息
let GET_ALL_CATEGORIES = "api/getAllCategories.api"

/// 根据分类id查询视频信息列表
let GET_VIDEO_INFOS_LIST = "api/getVideoInfosList.api"

/// 根据视频信息id查询视频播放列表
let GET_VIDEO_LIST = "api/getVideoList.api"

/// 获取动弹列表
let GET_TWEETS_LIST = "api/getTweetsList.api"

/// 获取动弹列表
let GET_TWEETS_DETAIL = "api/getTweetsDetail.api"

/// 发布动弹
let POST_TWEETS = "api/postTweets.api"

/// 获取评论列表
let GET_COMMENT_LIST = "api/getCommentList.api"

/// 发布评论
let POST_COMMENT = "api/postComment.api"

/// 获取语法手册
let GET_GRAMMAR_MANUAL = "api/getGramarManual.api"

/// 获取朋友关系列表 粉丝、关注
let GET_FRIEND_LIST = "api/getFriendList.api"

/// 添加或取消赞
let ADD_OR_CANCEL_LIKE_RECORD = "api/addOrCancelLikeRecord.api"



