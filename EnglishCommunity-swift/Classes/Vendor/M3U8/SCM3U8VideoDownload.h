//
//  SCM3U8VideoDownload.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFCommonOC.h"

/*
 M3U8格式视频下载类：下载单个视频时直接使用，下载多个视频时需要写个管理单例类
 状态改变：等待->(开始)下载，下载->暂停，暂停->(继续)下载，失败->(重新)下载；
 总之：未完成状态下，未下载->下载，下载->暂停
 实际去下载的时候需要考虑网络情况变化，磁盘剩余空间，甚至手机当前电量等
 */

@protocol SCM3U8VideoDownloadDelegate <NSObject>

- (void)M3U8VideoDownloadParseFailWithVideoId:(NSString *)videoId videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index;
- (void)M3U8VideoDownloadFinishWithVideoId:(NSString *)videoId localPath:(NSString *)path videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index;
- (void)M3U8VideoDownloadFailWithVideoId:(NSString *)videoId videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index;
- (void)M3U8VideoDownloadProgress:(CGFloat)progress withVideoId:(NSString *)videoId videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index;

@end

@interface SCM3U8VideoDownload : NSObject

@property (assign, nonatomic) id<SCM3U8VideoDownloadDelegate>delegate;
@property (assign, nonatomic) DownloadVideoState downloadState;
@property (copy, nonatomic) NSString *vid;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger videoInfoId;

- (instancetype)initWithVideoId:(NSString *)vid VideoUrl:(NSString *)videoUrl videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index;

- (void)changeDownloadVideoState;

- (void)deleteDownloadVideo;

@end
