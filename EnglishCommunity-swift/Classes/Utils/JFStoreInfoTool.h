//
//  JFStoreInfoTool.h
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFStoreInfoTool : NSObject

/**
 *  获取硬盘总容量
 *
 *  @return 容量字符串
 */
+ (NSString *)getTotalDiskSize;

/**
 *  获取硬盘已经占用的
 *
 *  @return 容量字符串
 */
+ (NSString *)getOccupyDiskSize;

/**
 *  获取硬盘可以容量
 *
 *  @return 容量字符串
 */
+ (NSString *)getAvailableDiskSize;

/**
 *  计算文件夹下文件的总大小
 *
 *  @param path 目录路径
 *
 *  @return 返回大小
 */
+ (float )folderSizeAtPath:(NSString*)folderPath;

@end
