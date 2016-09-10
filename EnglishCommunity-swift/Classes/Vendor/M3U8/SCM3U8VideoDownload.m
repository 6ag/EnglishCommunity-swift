//
//  SCM3U8VideoDownload.m
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import "SCM3U8VideoDownload.h"
#import "SCM3U8Analyse.h"
#import "SCM3U8SegmentListDownload.h"
#import "JFCommonOC.h"

@interface SCM3U8VideoDownload ()<SCM3U8AnalyseDelegate,SCM3U8SegmentListDownloadDelegate>

@property (copy, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) SCM3U8Analyse *m3u8Analyse;
@property (strong, nonatomic) SCM3U8SegmentListDownload *listDownload;
@property (assign, nonatomic) BOOL analyseDataFinish;

@end

@implementation SCM3U8VideoDownload

- (instancetype)initWithVideoId:(NSString *)vid VideoUrl:(NSString *)videoUrl videoInfoId:(NSInteger)videoInfoId index:(NSInteger)index
{
    if(self = [super init]){
        self.index = index;
        self.videoInfoId = videoInfoId;
        self.vid = vid;
        self.videoUrl = videoUrl;
        self.downloadState = DownloadVideoStateWating;
    }
    return self;
}

- (void)analyseM3U8VideoUrl
{
    //注意不论是解析字符串还是实际去下载都需要单开一个线程
    if(!_m3u8Analyse){
        _m3u8Analyse = [[SCM3U8Analyse alloc] init];
        _m3u8Analyse.delegate = self;
    }
    dispatch_queue_t myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(myQueue, ^{
        [_m3u8Analyse analyseVideoUrl:_videoUrl];
    });
}

- (void)changeDownloadVideoState
{
    switch (self.downloadState) {
        case DownloadVideoStateWating:
        {
            //去解析，解析成功去下载
            [self analyseM3U8VideoUrl];
            self.downloadState = DownloadVideoStateDownloading;
        }
            break;
        case DownloadVideoStateDownloading:
        {
            //暂停下载
            [self pauseDownloadVideo];
            self.downloadState = DownloadVideoStatePausing;
        }
            break;
        case DownloadVideoStatePausing:
        {
            //继续下载
            [self startDownloadVideo];
            self.downloadState = DownloadVideoStateDownloading;
        }
            break;
        case DownloadVideoStateFail:
        {
            //重新下载
            if(self.analyseDataFinish){
                [self startDownloadVideo];
            }
            else{
                [self analyseM3U8VideoUrl];
            }
            self.downloadState = DownloadVideoStateDownloading;
        }
            break;
        default:
            break;
    }
}

- (void)startDownloadVideo
{
    if(!_listDownload){
        _listDownload = [[SCM3U8SegmentListDownload alloc] initWithSegmentList:_m3u8Analyse.segmentList];
        _listDownload.vid = self.vid;
        _listDownload.delegate = self;
    }
    [_listDownload startDownloadVideo];
}

- (void)pauseDownloadVideo
{
    [_listDownload pauseDownloadVideo];
}

- (void)deleteDownloadVideo
{
    [_listDownload cancelDownloadVideo];
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.vid];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if([fileManager fileExistsAtPath:savePath isDirectory:&isDir]){
        [fileManager removeItemAtPath:savePath error:nil];
    }
    self.downloadState = DownloadVideoStateWating;
    self.analyseDataFinish = NO;
    self.listDownload.delegate = nil;
    self.listDownload = nil;
}

#pragma mark --- SCM3U8AnalyseDelegate ---

/**
 *  解析完成，开始下载视频
 */
- (void)M3U8AnalyseFinish
{
    self.analyseDataFinish = YES;
    if(self.downloadState==DownloadVideoStateDownloading){
        [self startDownloadVideo];
    }
}

/**
 *  解析失败
 *
 *  @param error 错误
 */
- (void)M3U8AnalyseFail:(NSError *)error
{
    NSLog(@"error.code is %ld",error.code);
    self.downloadState = DownloadVideoStateFail;
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8VideoDownloadParseFailWithVideoId:videoInfoId:index:)]){
        [self.delegate M3U8VideoDownloadParseFailWithVideoId:self.vid videoInfoId:self.videoInfoId index:self.index];
    }
}

#pragma mark --- SCM3U8SegmentListDownloadDelegate ---

/**
 *  M3u8分段下载完成
 */
- (void)M3U8SegmentListDownloadFinished
{
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.vid];
    NSString *fullPath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
    
    self.downloadState = DownloadVideoStateFinish;
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8VideoDownloadFinishWithVideoId:localPath:videoInfoId:index:)]){
        [self.delegate M3U8VideoDownloadFinishWithVideoId:self.vid localPath:fullPath videoInfoId:self.videoInfoId index:self.index];
    }
}

/**
 *  m3u8分段下载失败
 */
- (void)M3U8SegmentListDownloadFailed
{
    self.downloadState = DownloadVideoStateFail;
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8VideoDownloadFailWithVideoId:videoInfoId:index:)]){
        [self.delegate M3U8VideoDownloadFailWithVideoId:self.vid videoInfoId:self.videoInfoId index:self.index];
    }
}

/**
 *  m3u8分段下载进度
 *
 *  @param progress 进度
 */
- (void)M3U8SegmentListDownloadProgress:(CGFloat)progress
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8VideoDownloadProgress:withVideoId:videoInfoId:index:)]){
        [self.delegate M3U8VideoDownloadProgress:progress withVideoId:self.vid videoInfoId:self.videoInfoId index:self.index];
    }
}

@end


