//
//  JFCommonOC.h
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 9/8/16.
//  Copyright © 2016 zhoujianfeng. All rights reserved.
//

typedef NS_ENUM(NSInteger, DownloadVideoState){
    DownloadVideoStateDownloading = 1,
    DownloadVideoStateWating = 2,
    DownloadVideoStatePausing = 3,
    DownloadVideoStateFail = 4,
    DownloadVideoStateFinish = 5,
};

typedef NS_ENUM(NSInteger, M3U8AnalyseFail){
    M3U8AnalyseFailNotM3U8Url = 1,
    M3U8AnalyseFailNetworkUnConnection = 2,
};

#define kPathDownload @"DownloadVideos"
#define kTestDownloadingFileSuffix @"_etc"