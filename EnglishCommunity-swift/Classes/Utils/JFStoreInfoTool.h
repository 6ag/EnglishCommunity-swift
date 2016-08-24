//
//  JFStoreInfoTool.h
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
