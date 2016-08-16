//
//  String+Extension.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/2/22.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import Foundation

extension String {
    
    /**
     时间戳转为时间
     
     - returns: 时间字符串
     */
    func timeStampToString() -> String {
        let string = NSString(string: self)
        let timeSta: NSTimeInterval = string.doubleValue
        let dfmatter = NSDateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = NSDate(timeIntervalSince1970: timeSta)
        return dfmatter.stringFromDate(date)
    }
    
    /**
     时间戳转为NSDate
     
     - returns: NSDate
     */
    func timeStampToDate() -> NSDate {
        let string = NSString(string: self)
        let timeSta: NSTimeInterval = string.doubleValue
        let date = NSDate(timeIntervalSince1970: timeSta)
        return date
    }
    
    /**
     时间转为时间戳
     
     - returns: 时间戳字符串
     */
    func stringToTimeStamp() -> String {
        let dfmatter = NSDateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dfmatter.dateFromString(self)
        let dateStamp: NSTimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        return String(dateSt)
    }
    
    /**
     传入cell文本内容，解析成元素为昵称的数组
     
     - returns: 昵称数组
     */
    func checkAtUserNickname() -> [String]? {
        do {
            let pattern = "@\\S*"
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            let results = regex.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count))
            
            var resultStrings = [String]()
            for result in results {
                resultStrings.append(String((self as NSString).substringWithRange(result.range)))
            }
            return resultStrings
        }
        catch {
            return nil
        }
    }
}