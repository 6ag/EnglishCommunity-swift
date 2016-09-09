//
//  JFStoreInfoTool.m
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

#import "JFStoreInfoTool.h"
#import <UIKit/UIKit.h>
#import <sys/mount.h>

@implementation JFStoreInfoTool

/**
 *  获取硬盘总容量
 *
 *  @return 容量字符串
 */
+ (NSString *)getTotalDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return [JFStoreInfoTool fileSizeToString:freeSpace];
}

/**
 *  获取硬盘已经占用的
 *
 *  @return 容量字符串
 */
+ (NSString *)getOccupyDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks) - (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return [JFStoreInfoTool fileSizeToString:freeSpace];
}

/**
 *  获取硬盘可以容量
 *
 *  @return 容量字符串
 */
+ (NSString *)getAvailableDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return [JFStoreInfoTool fileSizeToString:freeSpace];
}

/**
 *  将数值型文件大小转为字符串
 *
 *  @param fileSize 文件大小
 *
 *  @return 字符串描述大小
 */
+ (NSString *)fileSizeToString:(unsigned long long)fileSize
{
    NSInteger KB = 1024;
    NSInteger MB = KB * KB;
    NSInteger GB = MB * KB;
    
    if (fileSize < 10) {
        return @"0 B";
    } else if (fileSize < KB) {
        return @"< 1 KB";
    } else if (fileSize < MB) {
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize) / KB];
    } else if (fileSize < GB) {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize) / MB];
    } else {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize) / GB];
    }
}

/**
 *  计算文件夹下文件的总大小
 *
 *  @param path 目录路径
 *
 *  @return 返回大小
 */
+ (float)folderSizeAtPath:(NSString *)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

/**
 *  单个文件的大小
 *
 *  @param filePath 文件路径
 *
 *  @return 尺寸
 */
+ (long long)fileSizeAtPath:(NSString *)filePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end
