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
    
    private func prepareVc() {
        
        let essenceVc = JFHomeViewController()
        configChildViewController(essenceVc, title: "首页", imageName: "tabbar_video_icon_normal", selectedImageName: "tabbar_video_icon_selected")
        
        let newVc = JFGrammarViewController()
        configChildViewController(newVc, title: "手册", imageName: "tabbar_grammar_icon_normal", selectedImageName: "tabbar_grammar_icon_selected")
        
        let friendTrendsVc = JFTweetViewController()
        configChildViewController(friendTrendsVc, title: "动态", imageName: "tabbar_trends_icon_normal", selectedImageName: "tabbar_trends_icon_selected")
        
        let profileVc = JFProfileViewController()
        configChildViewController(profileVc, title: "我的", imageName: "tab_profile_icon_normal", selectedImageName: "tab_profile_icon_selected")
    }
    
    /**
     配置TabBarController的子控制器
     
     - parameter childViewController: 子控制器
     - parameter title:               标题
     - parameter imageName:           默认图片名
     - parameter selectedImageName:   选中图片名
     */
    private func configChildViewController(childViewController: UIViewController, title: String, imageName: String, selectedImageName: String) {
        childViewController.title = title
        childViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        childViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12)], forState: UIControlState.Normal)
        childViewController.tabBarItem.image = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysOriginal)
        childViewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.imageWithRenderingMode(.AlwaysOriginal)
        let navigationC = JFNavigationController(rootViewController: childViewController)
        addChildViewController(navigationC)
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
        presentViewController(vc, animated: true, completion: nil)
    }
}


