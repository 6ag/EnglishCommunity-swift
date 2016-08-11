//
//  NSDate+Extension.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/4.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

extension NSDate {
    
    /**
     格式化NSDate为字符串
     */
    func dateToDescription() -> String {
        // ios比较日期使用 NSCalendar
        let calendar = NSCalendar.currentCalendar()
        
        // 判断是否是今天
        if calendar.isDateInToday(self) {
            // 获取系统当前日期和self比较,相差多少秒
            let delta = Int(NSDate().timeIntervalSinceDate(self))
            
            // 判断是否是一分钟内
            if delta < 60 {
                return "刚刚"
            } else if delta < 60 * 60 {
                // 一小时内
                return "\(delta / 60) 分钟前"
            } else {
                return "\(delta / 60 / 60) 小时前"
            }
        }
        
        var fmt = ""
        
        if calendar.isDateInYesterday(self) {
            // 昨天 HH:mm
            fmt = "昨天 HH:mm"
        } else {
            // 判断是一年内,还是更早期
            // 比较时间
            // date1: 比较的时间1
            // toDate: 比较的时间2
            // toUnitGranularity: 比较的单位
            let result = calendar.compareDate(self, toDate: NSDate(), toUnitGranularity: NSCalendarUnit.Year)
            // 表示同一年
            if result == NSComparisonResult.OrderedSame {
                // 一年内
                // MM-dd HH:mm(一年内)
                fmt = "MM-dd HH:mm"
            } else {
                // 一年外
                fmt = "yyyy-MM-dd HH:mm"
            }
        }
        
        // 让系统的NSDate根据指定的格式转成字符串
        let df = NSDateFormatter()
        
        // 指定格式
        df.dateFormat = fmt
        df.locale = NSLocale(localeIdentifier: "cn")
        
        // 将系统时间转成指定格式的字符串
        let dateStirng = df.stringFromDate(self)
        return dateStirng
    }
}