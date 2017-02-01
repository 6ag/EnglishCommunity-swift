//
//  JFNavigationController.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/16.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFNavigationController: UINavigationController {
    
    /**
     类加载的时候调用，swift里默认不提示了。。。。
     */
    override class func initialize() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = navigationBar
        navBar.barTintColor = COLOR_NAV_BG
        navBar.isTranslucent = false
        navBar.barStyle = UIBarStyle.black
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        
        // 导航栏背景色
        navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName : COLOR_NAV_ITEM_NORMAL
        ]
        
    }
    
    /**
     拦截push操作，修改需要push的控制器的返回按钮
     
     - parameter viewController: 需要push的控制器
     - parameter animated:       是否有push动画
     */
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if childViewControllers.count > 0 {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.leftItem("top_navigation_back_normal", highlightedImage: "top_navigation_back_normal", target: self, action: #selector(didTappedBackButton(_:)))
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    /**
     返回事件
     */
    @objc fileprivate func didTappedBackButton(_ button: UIBarButtonItem) {
        popViewController(animated: true)
    }
    
}
