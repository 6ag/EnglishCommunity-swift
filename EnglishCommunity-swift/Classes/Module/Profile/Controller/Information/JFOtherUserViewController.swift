//
//  JFOtherUserViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/21.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFOtherUserViewController: JFBaseTableViewController {

    var userId: Int = 0 {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        title = "用户关系"
        view.backgroundColor = COLOR_ALL_BG
        
    }

}
