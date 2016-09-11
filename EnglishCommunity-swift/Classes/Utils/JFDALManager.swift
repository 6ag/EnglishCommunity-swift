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
}

// MARK: - 视频缓存
extension JFDALManager {
    
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
    
}
