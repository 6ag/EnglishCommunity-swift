//
//  JFSQLiteManager.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/12.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import FMDB

let VIDEOS_TABLE = "jf_videos"

class JFSQLiteManager: NSObject {
    
    /// FMDB单例
    static let shareManager = JFSQLiteManager()
    
    /// sqlite数据库名
    private let dbName = "videos.db"
    
    let dbQueue: FMDatabaseQueue
    
    override init() {
        let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        let dbPath = "\(documentPath)/\(dbName)"
        print(dbPath)
        
        dbQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        
        createVideoInfosTable(VIDEOS_TABLE)
    }
    
    /**
     创建视频信息的数据表
     
     - parameter tbname: 表名
     */
    func createVideoInfosTable(tbname: String) {
        
        let sql = "CREATE TABLE IF NOT EXISTS \(tbname) ( \n" +
            "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \n" +
            "video_vid VARCHAR \n" +
            "createTime VARCHAR(30) DEFAULT (datetime('now', 'localtime')) \n" +
        ");"
        
        dbQueue.inDatabase { (db) in
            if db.executeStatements(sql) {
                print("创建 \(tbname) 表成功")
            } else {
                print("创建 \(tbname) 表失败")
            }
        }
    }
    
}
