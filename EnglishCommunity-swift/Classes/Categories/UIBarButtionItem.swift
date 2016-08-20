//
//  UIBarButtionItem.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/28.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    /**
     创建只带文字的item
     
     - parameter title:  标题
     - parameter target: 监听方法对象
     - parameter action: 方法选择器
     
     - returns: barButtonItem
     */
    class func leftItem(title: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let itemButton = UIButton(type: .Custom)
        itemButton.size = CGSize(width: 50, height: 44)
        itemButton.contentHorizontalAlignment = .Left
        itemButton.setTitle(title, forState: .Normal)
        itemButton.titleLabel?.font = UIFont.systemFontOfSize(18)
        itemButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: itemButton)
    }
    
    /**
     创建只带文字的item
     
     - parameter title:  标题
     - parameter target: 监听方法对象
     - parameter action: 方法选择器
     
     - returns: barButtonItem
     */
    class func rightItem(title: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let itemButton = UIButton(type: .Custom)
        itemButton.size = CGSize(width: 50, height: 44)
        itemButton.contentHorizontalAlignment = .Right
        itemButton.setTitle(title, forState: .Normal)
        itemButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        itemButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        itemButton.setTitleColor(UIColor(white: 0.9, alpha: 1), forState: .Disabled)
        itemButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: itemButton)
    }
    
    /**
     快速创建一个图标barButtonItem 左边
     
     - parameter normalImage:      默认图片名
     - parameter highlightedImage: 高亮图片名
     - parameter target:           监听方法对象
     - parameter action:           方法选择器
     
     - returns: barButtonItem
     */
    class func leftItem(normalImage: String, highlightedImage: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let itemButton = UIButton(type: .Custom)
        itemButton.size = CGSize(width: 50, height: 44)
        itemButton.contentHorizontalAlignment = .Left
        itemButton.setImage(UIImage(named: normalImage), forState: .Normal)
        itemButton.setImage(UIImage(named: highlightedImage), forState: .Highlighted)
        itemButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: itemButton)
    }
    
    /**
     快速创建一个图标barButtonItem 右边
     
     - parameter normalImage:      默认图片名
     - parameter highlightedImage: 高亮图片名
     - parameter target:           监听方法对象
     - parameter action:           方法选择器
     
     - returns: barButtonItem
     */
    class func rightItem(normalImage: String, highlightedImage: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let itemButton = UIButton(type: .Custom)
        itemButton.size = CGSize(width: 50, height: 44)
        itemButton.contentHorizontalAlignment = .Right
        itemButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        itemButton.setImage(UIImage(named: normalImage), forState: .Normal)
        itemButton.setImage(UIImage(named: highlightedImage), forState: .Highlighted)
        itemButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: itemButton)
    }
    
    /**
     快速创建一个带标题的barButtonItem 左边
     
     - parameter title:            标题
     - parameter normalImage:      默认图片名
     - parameter highlightedImage: 高亮图片名
     - parameter target:           监听方法对象
     - parameter action:           方法选择器
     
     - returns: barButtonItem
     */
    class func item(title: String, normalImage: String, highlightedImage: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let itemButton = UIButton(type: .Custom)
        itemButton.setTitle("返回", forState: .Normal)
        itemButton.size = CGSize(width: 50, height: 44)
        itemButton.setTitleColor(COLOR_NAV_ITEM_NORMAL, forState: .Normal)
        itemButton.setTitleColor(COLOR_NAV_ITEM_HIGH, forState: .Highlighted)
        itemButton.contentHorizontalAlignment = .Left
        itemButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        itemButton.setImage(UIImage(named: normalImage), forState: .Normal)
        itemButton.setImage(UIImage(named: highlightedImage), forState: .Highlighted)
        itemButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: itemButton)
    }
    
}
