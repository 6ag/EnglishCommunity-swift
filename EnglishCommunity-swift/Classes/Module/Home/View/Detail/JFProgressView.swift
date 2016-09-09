//
//  JFProgressView.swift
//  JianSan Wallpaper
//
//  Created by zhoujianfeng on 16/4/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProgressView: UIView {
    
    /// 进度
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 半径默认 50
    var radius: CGFloat = 10
    
    /// 线宽
    var lineWidth: CGFloat = 2
    
    /// 背景圆颜色
    var trackColor = UIColor(red:0.843,  green:0.843,  blue:0.843, alpha:1)
    
    /// 进度条颜色
    var progressColor = COLOR_NAV_BG
    
    override func drawRect(rect: CGRect) {
        
        // 背景
        let trackPath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius - lineWidth, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI * 2), clockwise: true)
        trackPath.lineWidth = lineWidth
        trackColor.setStroke()
        trackPath.stroke()
        
        // 进度
        let endAngle = CGFloat(M_PI * 2) * progress - CGFloat(M_PI_2)
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius - lineWidth, startAngle: CGFloat(-M_PI_2), endAngle: endAngle, clockwise: true)
        progressPath.lineWidth = lineWidth
        progressPath.lineCapStyle = CGLineCap.Round
        progressColor.setStroke()
        progressPath.stroke()
    }
    
}
