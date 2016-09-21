//
//  JFPlayerManager.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/3.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

public let JFPlayerConf = JFPlayerManager.shared

public enum JFPlayerTopBarShowCase: Int {
    case Always         = 0 /// 始终显示
    case HorizantalOnly = 1 /// 只在横屏界面显示
    case None           = 2 /// 不显示
}

public class JFPlayerManager {
    
    /// 单例
    public static let shared = JFPlayerManager()
    
    /// 主题色
    public var tintColor   = UIColor.whiteColor()
    
    /// Loader样式
    public var loaderType  = NVActivityIndicatorType.BallRotateChase
    
    /// 是否自动播放
    public var shouldAutoPlay = true
    
    public var topBarShowInCase = JFPlayerTopBarShowCase.Always
    
    /// 是否显示慢放和镜像按钮
    public var slowAndMirror = false
    
    /// 是否打印log
    public var allowLog  = false
    
    /**
     打印log
     
     - parameter info: log信息
     */
    func log(info:String) {
        if allowLog {
            print(info)
        }
    }
}