//
//  SCM3U8SegmentDownload.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 M3U8一个视频小片段下载类
 这个类中用到文件下载功能
 */

@class SCM3U8SegmentDownload;

@protocol SCM3U8SegmentDownloadDelegate <NSObject>

-(void)M3U8SegmentDownloadFinished:(SCM3U8SegmentDownload *)segmentDownload;
-(void)M3U8SegmentDownloadFailed:(SCM3U8SegmentDownload *)segmentDownload;
-(void)M3U8SegmentDownloadProgress:(CGFloat)progress;

@end

@interface SCM3U8SegmentDownload : NSObject

@property (assign, nonatomic) id<SCM3U8SegmentDownloadDelegate>delegate;

- (id)initWithUrl:(NSString *)url FilePath:(NSString *)path FileName:(NSString *)name;

- (void)start;

- (void)pause;

- (void)cancel;

@end
