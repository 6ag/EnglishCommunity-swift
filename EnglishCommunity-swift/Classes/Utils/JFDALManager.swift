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
        let sql = "DELETE FROM \(VIDEOS_TABLE) WHERE createTime < '\(overString)';"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) -> Void in
            if db.executeStatements(sql) {
                //                print("清除缓存数据成功")
            }
        }
    }
    
    /**
     插入视频
     
     - parameter videoVid: 视频vid
     */
    func insertVideo(videoVid: String) {
        
        getVideo(videoVid) { (have) in
            if have {
                print(videoVid, "已经存在")
                return
            }
        }
        
        let sql = "INSERT INTO \(VIDEOS_TABLE) (video_vid) VALUES (\"\(videoVid)\");"
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
            if db.executeStatements(sql) {
                print("插入成功")
            }
        }
        
    }
    
    /**
     移除单个视频
     
     - parameter videoVid: 视频vid
     */
    func removeVideo(videoVid: String, finished: (success: Bool) -> ()) {
        
        let sql = "DELETE FROM \(VIDEOS_TABLE) WHERE video_vid = \"\(videoVid)\";"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
            if db.executeStatements(sql) {
                finished(success: true)
                print("移除成功")
            } else {
                finished(success: false)
            }
        }
        
    }
    
    /**
     清除所有视频缓存
     */
    func removeAllVideo(finished: (success: Bool) -> ()) {
        
        let sql = "DROP TABLE IF EXISTS \(VIDEOS_TABLE);"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
            if db.executeStatements(sql) {
                finished(success: true)
                print("清除视频缓存数据成功")
            } else {
                finished(success: false)
            }
        }
        
        // 重新创建表
        JFSQLiteManager.shareManager.createVideoInfosTable(VIDEOS_TABLE)
    }
    
    /**
     获取视频
     
     - parameter videoVid: 视频vid
     - parameter finished: 返回回调
     */
    func getVideo(videoVid: String, finished: (have: Bool) -> ()) {
        
        let sql = "SELECT * FROM \(VIDEOS_TABLE) WHERE video_vid=\"\(videoVid)\" LIMIT 1;"
        
        JFSQLiteManager.shareManager.dbQueue.inDatabase { (db) in
            
            let result = try! db.executeQuery(sql, values: nil)
            while result.next() {
                finished(have: true)
                result.close()
                return
            }
            
            finished(have: false)
        }
    }
    
}