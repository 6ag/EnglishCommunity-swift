//
//  SCM3U8SegmentList.m
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import "SCM3U8SegmentList.h"

@implementation SCM3U8SegmentList

- (id)initWithSegments:(NSMutableArray *)segments
{
    if(self = [super init]){
        self.segments = segments;
    }
    return self;
}

- (SCM3U8SegmentInfo *)getSegmentWithIndex:(NSInteger)index
{
    return [self.segments objectAtIndex:index];
}

@end
