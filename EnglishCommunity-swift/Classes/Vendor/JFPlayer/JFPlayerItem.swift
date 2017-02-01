//
//  JFPlayerItem.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/3.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

open class JFPlayerItem {
    
    var title: String
    var resource: [JFPlayerItemDefinitionItem]
    var cover: String
    
    public init(title: String, resource : [JFPlayerItemDefinitionItem], cover :String = "") {
        self.title    = title
        self.resource = resource
        self.cover    = cover
    }
}

open class JFPlayerItemDefinitionItem {
    
    open var playURL: URL
    open var definitionName: String
    
    /**
     初始化播放资源
     
     - parameter url:         资源URL
     - parameter qualityName: 资源清晰度标签
     */
    public init(url: URL, definitionName: String) {
        self.playURL        = url
        self.definitionName = definitionName
    }
}
