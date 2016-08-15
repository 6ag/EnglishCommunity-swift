//
//  JFTabBar.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/28.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTabBar: UITabBar {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bgImage = UIImage(named: "tab_background")?.resizableImageWithCapInsets(UIEdgeInsets(top: 40, left: 100, bottom: 40, right: 100), resizingMode: UIImageResizingMode.Stretch)
        backgroundImage = bgImage
        shadowImage = UIImage()
        
        // 中间加号按钮
        let addButton = UIButton(type: .Custom)
        addButton.setImage(UIImage(named: "tabbar_publish_icon_normal"), forState: .Normal)
        addButton.setImage(UIImage(named: "tabbar_publish_icon_selected"), forState: .Highlighted)
        addButton.size = CGSize(width: SCREEN_WIDTH / 5, height: 49)
        addButton.center = CGPoint(x: SCREEN_WIDTH * 0.5, y: 49 * 0.5 + 6)
        addButton.addTarget(self, action: #selector(didTappedAddButton(_:)), forControlEvents: .TouchUpInside)
        addSubview(addButton)
    }
    
    /**
     +号按钮点击事件
     */
    @objc private func didTappedAddButton(button: UIButton) {
        print("+ 点击")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 重新布局tabBarButton
        let y: CGFloat = 15
        let width: CGFloat = SCREEN_WIDTH / 5
        let height: CGFloat = 49
        
        var index = 0
        for view in subviews {
            if !view.isKindOfClass(NSClassFromString("UITabBarButton")!) {
                continue
            }
            let x = CGFloat(index > 1 ? index + 1 : index) * width
            view.frame = CGRect(x: x, y: y, width: width, height: height)
            index += 1
        }
        
    }
    
}
