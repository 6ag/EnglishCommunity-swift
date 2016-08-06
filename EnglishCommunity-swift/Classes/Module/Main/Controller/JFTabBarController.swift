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
        
        setValue(JFTabBar(), forKey: "tabBar")
        
        prepareVc()
    }
    
    private func prepareVc() {
        
        let essenceVc = JFHomeViewController()
        configChildViewController(essenceVc, title: "首页", imageName: "tabbar_video_icon_normal", selectedImageName: "tabbar_video_icon_selected")
        
        let newVc = JFExaminationViewController()
        configChildViewController(newVc, title: "题库", imageName: "tabbar_examination_icon_normal", selectedImageName: "tabbar_examination_icon_selected")
        
        let friendTrendsVc = JFTrendsViewController()
        configChildViewController(friendTrendsVc, title: "动态", imageName: "tabbar_trends_icon_normal", selectedImageName: "tabbar_trends_icon_selected")
        
        let profileVc = JFProfileViewController()
        configChildViewController(profileVc, title: "我", imageName: "tab_profile_icon_normal", selectedImageName: "tab_profile_icon_selected")
    }
    
    /**
     配置TabBarController的子控制器
     
     - parameter childViewController: 子控制器
     - parameter title:               标题
     - parameter imageName:           默认图片名
     - parameter selectedImageName:   选中图片名
     */
    private func configChildViewController(childViewController: UIViewController, title: String, imageName: String, selectedImageName: String) {
        childViewController.navigationItem.title = title
        childViewController.tabBarItem.image = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysOriginal)
        childViewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.imageWithRenderingMode(.AlwaysOriginal)
        let navigationC = JFNavigationController(rootViewController: childViewController)
        addChildViewController(navigationC)
    }
    
    /**
     修改tabBar的高度
     */
    override func viewWillLayoutSubviews() {
        
        var tabFrame = tabBar.frame
        tabFrame.size.height = 60
        tabFrame.origin.y = SCREEN_HEIGHT - 60
        tabBar.frame = tabFrame
    }
}
