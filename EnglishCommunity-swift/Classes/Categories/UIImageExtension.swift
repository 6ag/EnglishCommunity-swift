//
//  UIImage+Extension.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/10.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

extension UIImage {
    
    /*
     指定宽度等比缩放
     
     - parameter newWidth: 需要缩放的宽度
     
     - returns: 返回缩放后的图片
     */
    func equalScaleWithWidth(_ newWidth: CGFloat) -> CGSize {
        // 新的高度 / 新的宽度 = 原来的高度 / 原来的宽度
        let newHeight = newWidth * (size.height * scale) / (size.width * scale)
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
    
    /**
     指定高度等比缩放
     
     - parameter newHeight: 需要缩放的高度
     
     - returns: 返回缩放后的图片
     */
    func equalScaleWithWHeight(_ newHeight: CGFloat) -> CGSize {
        // 新的高度 / 新的宽度 = 原来的高度 / 原来的宽度
        let newWidth = newHeight / (size.height * scale) * (size.width * scale)
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
    
    /**
     缩放图片到指定的尺寸
     
     - parameter newSize: 需要缩放的尺寸
     
     - returns: 返回缩放后的图片
     */
    func resizeImageWithNewSize(_ newSize: CGSize) -> UIImage {
        
        var rect = CGRect.zero
        let oldSize = self.size
        
        if newSize.width / newSize.height > oldSize.width / oldSize.height {
            rect.size.width = newSize.height * oldSize.width / oldSize.height
            rect.size.height = newSize.height
            rect.origin.x = (newSize.width - rect.size.width) * 0.5
            rect.origin.y = 0
        } else {
            rect.size.width = newSize.width
            rect.size.height = newSize.width * oldSize.height / oldSize.width
            rect.origin.x = 0
            rect.origin.y = (newSize.height - rect.size.height) * 0.5
        }
        
        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        UIRectFill(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
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
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        // 从上下文获取绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /// 重新绘制图片
    ///
    /// - Parameters:
    ///   - image: 原图
    ///   - size: 绘制尺寸
    /// - Returns: 新图
    func redrawImage(size: CGSize?) -> UIImage? {
        
        // 绘制区域
        let rect = CGRect(origin: CGPoint(), size: size ?? CGSize.zero)
        
        // 开启图形上下文 size:绘图的尺寸 opaque:不透明 scale:屏幕分辨率系数,0会选择当前设备的屏幕分辨率系数
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 绘制 在指定区域拉伸并绘制
        draw(in: rect)
        
        // 从图形上下文获取图片
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /// 重新绘制圆形图片
    ///
    /// - Parameters:
    ///   - image: 原图
    ///   - size: 绘制尺寸
    ///   - bgColor: 裁剪区域外的背景颜色
    /// - Returns: 新图
    func redrawOvalImage(size: CGSize?, bgColor: UIColor?) -> UIImage? {
        
        // 绘制区域
        let rect = CGRect(origin: CGPoint(), size: size ?? CGSize.zero)
        
        // 开启图形上下文 size:绘图的尺寸 opaque:不透明 scale:屏幕分辨率系数,0会选择当前设备的屏幕分辨率系数
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 背景颜色填充
        bgColor?.setFill()
        UIRectFill(rect)
        
        // 圆形路径
        let path = UIBezierPath(ovalIn: rect)
        
        // 进行路径裁切，后续的绘图都会出现在这个圆形路径内部
        path.addClip()
        
        // 绘制图像 在指定区域拉伸并绘制
        draw(in: rect)
        
        // 从图形上下文获取图片
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return result
    }

    
}
