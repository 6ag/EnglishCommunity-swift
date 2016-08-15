//
//  JFPhotoBrowserModalAnimation.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFPhotoBrowserModalAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 将将要modal出来的控制器的view添加到容器视图
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        transitionContext.containerView()?.addSubview(toView)
        
        // 获取Modal出来的控制器
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! JFPhotoBrowserViewController
        
        // 添加过渡的视图
        let tempImageView = toVC.modalTempImageView()
        transitionContext.containerView()?.addSubview(tempImageView)
        
        // 隐藏collectionView
        toVC.collectionView.hidden = true
        
        // 动画
        toView.alpha = 0
        UIView.animateWithDuration(transitionDuration(nil), animations: { () -> Void in
            // 设置透明
            toView.alpha = 1
            
            if toVC.modalTargetFrame() != nil {
                // 设置过渡视图的frame
                tempImageView.frame = toVC.modalTargetFrame()!
            }
            }) { (_) -> Void in
                // 移除过渡视图
                tempImageView.removeFromSuperview()
                
                // 显示collectioView
                toVC.collectionView.hidden = false
                
                // 转场完成
                transitionContext.completeTransition(true)
        }
    }
}
