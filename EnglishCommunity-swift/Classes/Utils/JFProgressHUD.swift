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
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0.0, alpha: 0.8))
        SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 16))
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
    }
    
    class func show() {
        SVProgressHUD.show()
    }
    
    class func showWithStatus(_ status: String) {
        SVProgressHUD.show(withStatus: status)
    }
    
    class func showInfoWithStatus(_ status: String) {
        SVProgressHUD.showInfo(withStatus: status)
    }
    
    class func showSuccessWithStatus(_ status: String) {
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    class func showErrorWithStatus(_ status: String) {
        SVProgressHUD.showError(withStatus: status)
    }
    
    class func dismiss() {
        SVProgressHUD.dismiss()
    }
    
}
