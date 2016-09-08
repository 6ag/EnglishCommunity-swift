//
//  SCM3U8SegmentDownload.m
//  VideoDownloadDemo
//
//  Created by 王琦 on 15/10/19.
//  Copyright (c) 2015年 Riverrun. All rights reserved.
//

#import "SCM3U8SegmentDownload.h"
#import "ASIHTTPRequest.h"
#import "ASIProgressDelegate.h"
#import "JFCommonOC.h"

@interface SCM3U8SegmentDownload ()<ASIProgressDelegate,ASIHTTPRequestDelegate>

@property (copy, nonatomic) NSString *fileUrl;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *fileName;

@property (copy, nonatomic) NSString *tmpFilePath;

@property (strong, nonatomic) ASIHTTPRequest *request;

@end

@implementation SCM3U8SegmentDownload

- (id)initWithUrl:(NSString *)url FilePath:(NSString *)path FileName:(NSString *)name
{
    if(self = [super init]){
        self.filePath = path;
        self.fileName = name;
        self.fileUrl = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        //这里针对不同的下载方法还需要改动下
        self.tmpFilePath = [NSString stringWithString:[savePath stringByAppendingPathComponent:[self.fileName stringByAppendingString:kTestDownloadingFileSuffix]]];
        BOOL isDir = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:savePath isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)start
{
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
    
    NSURL *URL = [NSURL URLWithString:[self.fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self.request = [ASIHTTPRequest requestWithURL:URL];
    [self.request setTemporaryFileDownloadPath:self.tmpFilePath];
    [self.request setDownloadDestinationPath:[savePath stringByAppendingPathComponent:self.fileName]];
    [self.request setDelegate:self];
    [self.request setDownloadProgressDelegate:self];
    self.request.allowResumeForFileDownloads = YES;
    [self.request setNumberOfTimesToRetryOnTimeout:2];
    [self.request startAsynchronous];
}

- (void)pause
{
    self.request.delegate = nil;
    [self.request cancelAuthentication];
}

- (void)cancel
{
    self.request.delegate = nil;
    [self.request cancelAuthentication];
}

#pragma mark --- ASIHTTPRequestDelegate ---

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSLog(@"download segment %@ success",self.fileName);
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadFinished:)]){
        [self.delegate M3U8SegmentDownloadFinished:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//    NSLog(@"download segment %@ fail",self.fileName);
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadFailed:)]){
        [self.delegate M3U8SegmentDownloadFailed:self];
    }
}

#pragma mark --- ASIProgressDelegate ---

- (void)setProgress:(float)newProgress
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadProgress:)]){
        [self.delegate M3U8SegmentDownloadProgress:newProgress];
    }
}

@end











