//
//  JFTabBarController.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/16.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = JFTabBar()
        tabBar.tabBarDelegate = self
        setValue(tabBar, forKey: "tabBar")
        tabBar.tintColor = COLOR_NAV_BG
        prepareVc()
    }
    
    fileprivate func prepareVc() {
        
        let essenceVc = JFHomeViewController()
        configChildViewController(essenceVc, title: "首页", imageName: "tabbar_video_icon_normal", selectedImageName: "tabbar_video_icon_selected")
        
        let newVc = JFGrammarViewController()
        configChildViewController(newVc, title: "语法", imageName: "tabbar_grammar_icon_normal", selectedImageName: "tabbar_grammar_icon_selected")
        
        let friendTrendsVc = JFTweetViewController()
        configChildViewController(friendTrendsVc, title: "动态", imageName: "tabbar_trends_icon_normal", selectedImageName: "tabbar_trends_icon_selected")
        
        let profileVc = JFProfileViewController()
        configChildViewController(profileVc, title: "我的", imageName: "tab_profile_icon_normal", selectedImageName: "tab_profile_icon_selected")
        
        // 布局完立马选中，防止崩溃
        selectedIndex = 0
    }
    
    /**
     配置TabBarController的子控制器
     
     - parameter childViewController: 子控制器
     - parameter title:               标题
     - parameter imageName:           默认图片名
     - parameter selectedImageName:   选中图片名
     */
    fileprivate func configChildViewController(_ childViewController: UIViewController, title: String, imageName: String, selectedImageName: String) {
        childViewController.title = title
        childViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        childViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 12)], for: UIControlState())
        childViewController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        childViewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        let navigationC = JFNavigationController(rootViewController: childViewController)
        addChildViewController(navigationC)
    }
    
    /**
     哪些控制器可以进行旋转
     */
    override var shouldAutorotate : Bool {
        guard let nav = self.viewControllers?[self.selectedIndex] as? JFNavigationController else {
            return false
        }
        guard let topVc = nav.topViewController else {
            return false
        }
        
        if topVc.isKind(of: JFPlayerViewController.classForCoder()) {
            return true
        }
        
        if topVc.isKind(of: JFWebPlayerViewController.classForCoder()) {
            return true
        }
        
        return false
    }
    
    /**
     支持哪些方向的旋转
     */
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        guard let nav = self.viewControllers?[self.selectedIndex] as? JFNavigationController else {
            return UIInterfaceOrientationMask.portrait
        }
        guard let topVc = nav.topViewController else {
            return UIInterfaceOrientationMask.portrait
        }
        
        if topVc.isKind(of: JFPlayerViewController.classForCoder()) {
            return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
        }
        
        if topVc.isKind(of: JFWebPlayerViewController.classForCoder()) {
            return [UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
        }
        
        return UIInterfaceOrientationMask.portrait
    }
    
}

// MARK: - JFTabBarDelegate
extension JFTabBarController: JFTabBarDelegate {
    
    /**
     点击了发布按钮
     */
    func didTappedAddButton() {
        
        let publishVc = JFNavigationController(rootViewController: JFPublishViewController())
        let loginVc = JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil))
        let vc = JFAccountModel.isLogin() ? publishVc : loginVc
        present(vc, animated: true, completion: nil)
    }
}


