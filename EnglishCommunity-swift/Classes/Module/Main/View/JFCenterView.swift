//
//  JFCenterView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFCenterView: UIView {

    let bgView = UIView(frame: SCREEN_BOUNDS) // 透明遮罩
    let viewHeight: CGFloat = 200
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        backgroundColor = UIColor.orangeColor()
    }
    
    /**
     弹出视图
     */
    func show() {
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.sharedApplication().keyWindow?.addSubview(bgView)
        
        frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: viewHeight)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformMakeTranslation(0, -self.viewHeight)
            self.bgView.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
        }) { (_) in
            
        }
        
    }
    
    /**
     隐藏视图
     */
    func dismiss() {
        UIView.animateWithDuration(0.25, animations: {
            self.transform = CGAffineTransformIdentity
            self.bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        }) { (_) in
            self.bgView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    /**
     透明背景遮罩触摸事件
     */
    @objc private func didTappedBgView(tap: UITapGestureRecognizer) {
        dismiss()
    }

}
