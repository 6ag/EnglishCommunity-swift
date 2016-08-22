//
//  JFProfileCellSwitchModel.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCellSwitchModel: JFProfileCellModel {
    
    /// 存储偏好设置的key
    var key: String?
    
    /// 状态
    var on: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(key!)
        }
        set(on) {
            NSUserDefaults.standardUserDefaults().setBool(on, forKey: key!)
        }
    }
    
    init(title: String, key: String) {
        super.init(title: title)
        self.key = key
    }
    
}
