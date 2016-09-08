//
//  SCM3U8SegmentInfo.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 M3U8一个视频小片段信息类
 */

@interface SCM3U8SegmentInfo : NSObject

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger duration;
@property (copy, nonatomic) NSString *url;

@end
