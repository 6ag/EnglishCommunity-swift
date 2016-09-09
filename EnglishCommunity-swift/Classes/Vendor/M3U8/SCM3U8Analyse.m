//
//  SCM3U8Analyse.m
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import "SCM3U8Analyse.h"
#import "SCM3U8SegmentList.h"
#import "Reachability.h"
#import "JFCommonOC.h"

@implementation SCM3U8Analyse

- (void)analyseVideoUrl:(NSString *)videoUrl
{
    NSRange rangeOfM3U8 = [videoUrl rangeOfString:@"m3u8"];
    if(rangeOfM3U8.location == NSNotFound){
        if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFail:)]){
            NSError *err = [NSError errorWithDomain:videoUrl code:M3U8AnalyseFailNotM3U8Url userInfo:nil];
            [self.delegate M3U8AnalyseFail:err];
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:videoUrl];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *data = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
    if(!data){
        if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFail:)]){
            NSError *err = [NSError errorWithDomain:videoUrl code:M3U8AnalyseFailNetworkUnConnection userInfo:nil];
            [self.delegate M3U8AnalyseFail:err];
        }
        return;
    }
    
    NSString *remainData = data;
//    NSLog(@"original data is %@",data);
    
    NSRange httpRange = [remainData rangeOfString:@"http"];
    if(httpRange.location == NSNotFound){
        //暂时只针对腾讯视频
        NSString *newString = @"av";
        NSRange range = [videoUrl rangeOfString:@"playlist.av.m3u8"];
        if(range.location != NSNotFound){
            newString = [NSString stringWithFormat:@"%@%@",[videoUrl substringToIndex:range.location],@"av"];
        }
        remainData = [remainData stringByReplacingOccurrencesOfString:@"av" withString:newString];
    }
    
    NSMutableArray *segments = [NSMutableArray array];
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    NSInteger segmentIndex = 0;
    NSInteger totalSeconds = 0;
    while (segmentRange.location != NSNotFound) {
        SCM3U8SegmentInfo *segment = [[SCM3U8SegmentInfo alloc] init];
        //读取片段时长
        NSRange commaRange = [remainData rangeOfString:@","];
        NSString *value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        totalSeconds+=segment.duration;
        remainData = [remainData substringFromIndex:commaRange.location];
        //读取片段url
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        NSString *linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.url = linkurl;
        segment.index = segmentIndex;
        
        segmentIndex++;
        [segments addObject:segment];
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    
    SCM3U8SegmentList *segmentList = [[SCM3U8SegmentList alloc] initWithSegments:segments];
    self.segmentList = segmentList;
    self.totalSeconds = totalSeconds;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFinish)]){
        [self.delegate M3U8AnalyseFinish];
    }
}

@end




