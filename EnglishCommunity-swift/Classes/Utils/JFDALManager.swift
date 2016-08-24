//
//  JFDALManager.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SwiftyJSON

class JFDALManager: NSObject {
    
    static let shareManager = JFDALManager()
    
    /// 过期时间间隔 从缓存开始计时，单位秒 7天
    private let timeInterval: NSTimeInterval = 86400 * 7
    
    /**
     在退出到后台的时候，根据缓存时间自动清除过期的缓存数据
     */
    func clearCacheData() {
        
        // 计算过期时间
        let overDate = NSDate(timeIntervalSinceNow: -timeInterval)
        
        // 记录时间格式 2016-06-13 02:29:37
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let overString = df.stringFromDate(overDate)
        
        // 生成sql语句
        let sql = "DELETE FROM \(VIDEO_INFOS_TABLE) WHERE createTime < '\(overString)';"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) -> Void in
            if db.executeStatements(sql) {
//                print("清除缓存数据成功")
            }
        }
    }
}