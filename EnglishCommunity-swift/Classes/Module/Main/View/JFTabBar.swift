//
//  JFTabBar.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/28.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFTabBarDelegate: NSObjectProtocol {
    func didTappedAddButton()
}

class JFTabBar: UITabBar {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shadowImage = UIImage()
        addSubview(addButton)
    }
    
    /// 自定义tabBar代理
    weak var tabBarDelegate: JFTabBarDelegate?
    
    /**
     +号按钮点击事件
     */
    @objc fileprivate func didTappedAddButton(_ button: UIButton) {
        tabBarDelegate?.didTappedAddButton()
    }
    
    /**
     重新布局tabBar子控件
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 重新布局tabBarButton
        let y: CGFloat = 0
        let width: CGFloat = SCREEN_WIDTH / 5
        let height: CGFloat = 49
        
        var index = 0
        for view in subviews {
            if !view.isKind(of: NSClassFromString("UITabBarButton")!) {
                // 隐藏tabBar顶部横线
                if view.isKind(of: NSClassFromString("UIImageView")!) && view.bounds.size.height <= 1 {
                    view.isHidden = true
                }
                continue
            }
            let x = CGFloat(index > 1 ? index + 1 : index) * width
            view.frame = CGRect(x: x, y: y, width: width, height: height)
            index += 1
        }
        
    }
    
    /**
     处理tabBar子控件的事件响应
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if point.y < 0 && point.x >= SCREEN_WIDTH / 5 * 2 && point.x <= SCREEN_WIDTH / 5 * 3 {
//            return addButton
//        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - 懒加载
    /// 中间 + 号按钮
    lazy var addButton: UIButton = {
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "tabbar_publish_icon_normal"), for: UIControlState())
        addButton.setImage(UIImage(named: "tabbar_publish_icon_selected"), for: .highlighted)
        addButton.size = CGSize(width: SCREEN_WIDTH / 5, height: SCREEN_WIDTH / 5)
        addButton.center = CGPoint(x: SCREEN_WIDTH * 0.5, y: 49 * 0.5 - 8)
        addButton.addTarget(self, action: #selector(didTappedAddButton(_:)), for: .touchUpInside)
        return addButton
    }()
    
}
