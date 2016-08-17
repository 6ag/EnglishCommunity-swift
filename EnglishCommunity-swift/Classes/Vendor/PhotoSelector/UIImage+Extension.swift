//
//  UIImage+Extension.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
    等比例缩小, 缩小到宽度等于300
    - returns: 缩小的图片
    */
    func scaleImage() -> UIImage {
        
        var newWidth: CGFloat = 700
        
        if size.width < 400 {
            return self
        } else if size.width < 500 {
            newWidth = 500
        } else if size.width < 600 {
            newWidth = 600
        }
        
        // 等比例缩放
        // newHeight / newWidth = 原来的高度 / 原来的宽度
        let newHeight = newWidth * size.height / size.width
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // 准备图片的上下文
        UIGraphicsBeginImageContext(newSize)
        
        // 将当前图片绘制到rect上面
        drawInRect(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        // 从上下文获取绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
