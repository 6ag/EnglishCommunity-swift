//
//  SCM3U8Analyse.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 M3U8字符串解析类
 */

@class SCM3U8Analyse;
@class SCM3U8SegmentList;

@protocol SCM3U8AnalyseDelegate <NSObject>

- (void)M3U8AnalyseFinish;
- (void)M3U8AnalyseFail:(NSError *)error;

@end

@interface SCM3U8Analyse : NSObject

@property (assign, nonatomic) id<SCM3U8AnalyseDelegate>delegate;
@property (strong, nonatomic) SCM3U8SegmentList *segmentList;
@property (assign, nonatomic) NSInteger totalSeconds;

- (void)analyseVideoUrl:(NSString *)videoUrl;

@end
