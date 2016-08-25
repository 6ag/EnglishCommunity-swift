//
//  Api.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import Foundation

/// 基URL
let BASE_URL = "http://english.6ag.cn/"

/// 发送手机验证码
let SEND_CODE = "api/auth/seedCode.api"

/// 注册
let REGISTER = "api/auth/register.api"

/// 登录
let LOGIN = "api/auth/login.api"

/// 修改用户密码
let MODIFY_USER_PASSWORD = "api/auth/modifyUserPassword.api"

/// 重置密码邮件
let RETRIEVE_PASSWORD_EMAIL = "api/auth/retrievePasswordWithSendEmail.api"

/// 获取所有分类信息
let GET_ALL_CATEGORIES = "api/getAllCategories.api"

/// 搜索视频信息列表
let SEARCH_VIDEO_INFO_LIST = "api/searchVideoInfoList.api"

/// 根据分类id查询视频信息列表
let GET_VIDEO_INFOS_LIST = "api/getVideoInfosList.api"

/// 获取视频信息
let GET_VIDEO_INFO_DETAIL = "api/getVideoInfoDetail.api"

/// 根据视频信息id查询视频播放列表
let GET_VIDEO_LIST = "api/getVideoList.api"

/// 解析m3u8地址
let PARSE_YOUKU_VIDEO = "api/playVideo.api"

/// 获取单个视频的视频分段列表地址
let GET_VIDEO_DOWNLOAD_LIST = "api/getVideoDownloadList.api"

/// 获取动弹列表
let GET_TWEETS_LIST = "api/getTweetsList.api"

/// 获取动弹详情
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

/// 获取收藏列表
let GET_COLLECTION_LIST = "api/getCollectionList.api"

/// 添加或删除视频收藏
let ADD_OR_CANCEL_COLLECTION = "api/addOrCancelCollectVideoInfo.api"

/// 上传用户头像
let UPLOAD_USER_AVATAR = "api/uploadUserAvatar.api"

/// 获取自己的用户信息
let GET_SELF_USER_INFOMATION = "api/getSelfUserInfomation.api"

/// 获取他人的用户信息
let GET_OTHER_USER_INFOMATION = "api/getOtherUserInfomation.api"

/// 更新用户信息
let UPDATE_USER_INFOMATION = "api/updateUserInfomation.api"

/// 添加或删除朋友
let ADD_OR_CANCEL_FRIEND = "api/addOrCancelFriend.api"

/// 提交反馈信息
let POST_FEEDBACK = "api/postFeedback.api"

/// 获取消息列表
let GET_MESSAGE_LIST = "api/getMessageList.api"

/// 获取未读消息数量
let GET_UNLOOKED_MESSAGE_COUNT = "api/getUnlookedMessageCount.api"

/// 清理未读消息数量
let CLEAR_UNLOOKED_MESSAGE = "api/clearUnlookedMessage.api"
