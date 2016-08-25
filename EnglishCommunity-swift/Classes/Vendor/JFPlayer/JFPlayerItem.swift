//
//  JFPlayerItem.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/3.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

public class JFPlayerItem {
    
    var title: String
    var resource: [JFPlayerItemDefinitionItem]
    var cover: String
    
    public init(title: String, resource : [JFPlayerItemDefinitionItem], cover :String = "") {
        self.title    = title
        self.resource = resource
        self.cover    = cover
    }
}

public class JFPlayerItemDefinitionItem {
    
    public var playURL: NSURL
    public var definitionName: String
    
    /**
     初始化播放资源
     
     - parameter url:         资源URL
     - parameter qualityName: 资源清晰度标签
     */
    public init(url: NSURL, definitionName: String) {
        self.playURL        = url
        self.definitionName = definitionName
    }
}