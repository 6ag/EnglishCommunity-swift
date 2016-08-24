//
//  JFProgressHUD.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/30.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SVProgressHUD

class JFProgressHUD: NSObject {
    
    class func setupHUD() {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Custom)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.0, alpha: 0.8))
        SVProgressHUD.setFont(UIFont.boldSystemFontOfSize(16))
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
    }
    
    class func show() {
        SVProgressHUD.show()
    }
    
    class func showWithStatus(status: String) {
        SVProgressHUD.showWithStatus(status)
    }
    
    class func showInfoWithStatus(status: String) {
        SVProgressHUD.showInfoWithStatus(status)
    }
    
    class func showSuccessWithStatus(status: String) {
        SVProgressHUD.showSuccessWithStatus(status)
    }
    
    class func showErrorWithStatus(status: String) {
        SVProgressHUD.showErrorWithStatus(status)
    }
    
    class func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}
