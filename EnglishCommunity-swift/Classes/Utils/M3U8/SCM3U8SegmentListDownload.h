//
//  SCM3U8SegmentListDownload.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCM3U8SegmentList.h"

/*
 M3U8视频小片段合集下载类
 如果有数据需要传递到外层的信息有：视频总大小，当前下载大小或百分比，当前下载速度
 为了便于管理，同一时间只下载一个小片段；
 因为每一段视频的大小都是不一样的，所以下载完成之前不知道具体视频大小
 */

@class SCM3U8SegmentListDownload;

@protocol SCM3U8SegmentListDownloadDelegate <NSObject>

-(void)M3U8SegmentListDownloadFinished;
-(void)M3U8SegmentListDownloadFailed;
-(void)M3U8SegmentListDownloadProgress:(CGFloat)progress;

@end

@interface SCM3U8SegmentListDownload : NSObject

@property (assign, nonatomic) id<SCM3U8SegmentListDownloadDelegate>delegate;
@property (strong, nonatomic) SCM3U8SegmentList *segmentList;
@property (copy, nonatomic) NSString *vid;

- (id)initWithSegmentList:(SCM3U8SegmentList *)segmentList;

- (void)startDownloadVideo;

- (void)pauseDownloadVideo;

- (void)cancelDownloadVideo;

@end
