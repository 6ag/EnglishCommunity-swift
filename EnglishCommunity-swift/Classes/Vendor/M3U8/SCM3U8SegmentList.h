//
//  SCM3U8SegmentList.h
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCM3U8SegmentInfo.h"

/*
 M3U8视频小片段合集类
 */

@interface SCM3U8SegmentList : NSObject

@property (strong, nonatomic) NSMutableArray *segments;

- (id)initWithSegments:(NSMutableArray *)segments;

- (SCM3U8SegmentInfo *)getSegmentWithIndex:(NSInteger)index;

@end
