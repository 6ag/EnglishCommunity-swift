//
//  SCM3U8SegmentListDownload.m
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import "SCM3U8SegmentListDownload.h"
#import "SCM3U8SegmentDownload.h"
#import "JFCommonOC.h"

@interface SCM3U8SegmentListDownload ()<SCM3U8SegmentDownloadDelegate>

@property (strong, nonatomic) NSMutableArray *downloadArray;

@end

@implementation SCM3U8SegmentListDownload

- (id)initWithSegmentList:(SCM3U8SegmentList *)segmentList
{
    if(self = [super init]){
        self.segmentList = segmentList;
    }
    return self;
}

- (void)startDownloadVideo
{
    if(!_downloadArray){
        self.downloadArray = [NSMutableArray array];
        NSInteger count = [self.segmentList.segments count];
        for(int i=0;i<count;i++){
            NSString *filename = [NSString stringWithFormat:@"id%d.ts",i];
            SCM3U8SegmentInfo *segment = [self.segmentList getSegmentWithIndex:i];
            SCM3U8SegmentDownload *segmentDownload = [[SCM3U8SegmentDownload alloc] initWithUrl:segment.url FilePath:self.vid FileName:filename];
            segmentDownload.delegate = self;
            [_downloadArray addObject:segmentDownload];
        }
    }
    if([_downloadArray count]){
        SCM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj start];
    }
}

- (void)pauseDownloadVideo
{
    if([_downloadArray count]){
        SCM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj pause];
    }
}

- (void)cancelDownloadVideo
{
    if([_downloadArray count]){
        SCM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj cancel];
    }
}

- (void)createLocalM3U8File
{
    if(self.segmentList){
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.vid];
        NSString *fullPath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
        NSInteger count = [self.segmentList.segments count];
        //填充片段数据
        for(int i = 0;i<count;i++) {
            NSString *filename = [NSString stringWithFormat:@"id%d.ts",i];
            SCM3U8SegmentInfo *segInfo = [self.segmentList getSegmentWithIndex:i];
            NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,filename];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        [writer writeToFile:fullPath atomically:YES];
    }
}

#pragma mark --- SCM3U8SegmentDownloadDelegate ---

- (void)M3U8SegmentDownloadProgress:(CGFloat)progress
{
    CGFloat oneSegmentDownloadProgress = progress*1.0/(float)self.segmentList.segments.count;
    CGFloat totalProgress = (oneSegmentDownloadProgress+(float)(self.segmentList.segments.count-_downloadArray.count)/(float)self.segmentList.segments.count)*100.0;
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadProgress:)]){
        [self.delegate M3U8SegmentListDownloadProgress:totalProgress];
    }
}

- (void)M3U8SegmentDownloadFinished:(SCM3U8SegmentDownload *)segmentDownload
{
    [_downloadArray removeObject:segmentDownload];
    if([_downloadArray count]){
        [self startDownloadVideo];
    }
    else{
        [self createLocalM3U8File];
        if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadFinished)]){
            [self.delegate M3U8SegmentListDownloadFinished];
        }
    }
}

- (void)M3U8SegmentDownloadFailed:(SCM3U8SegmentDownload *)segmentDownload
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadFailed)]){
        [self.delegate M3U8SegmentListDownloadFailed];
    }
}

@end

