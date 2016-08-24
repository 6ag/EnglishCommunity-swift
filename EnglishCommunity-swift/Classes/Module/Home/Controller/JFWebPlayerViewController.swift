//
//  JFWebPlayerViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFWebPlayerViewController: UIViewController {
    
    override func loadView() {
        view = webView
    }
    
    /// 视频模型
    var video: JFVideo? {
        didSet {
            guard let videoUrl = video?.videoUrl else {
                return
            }
            
            // 获取视频id
            var id = (videoUrl as NSString).stringByReplacingOccurrencesOfString("http://v.youku.com/v_show/id_", withString: "")
            id = (id as NSString).stringByReplacingOccurrencesOfString(".html", withString: "")
            
            // 通用播放代码
            let playerHTML = "<iframe height=\(SCREEN_WIDTH - 44) width=\(SCREEN_HEIGHT - 20) src='http://player.youku.com/embed/\(id)' frameborder=0 'allowfullscreen'></iframe>"
            
            JFProgressHUD.show()
            webView.loadHTMLString(playerHTML, baseURL: NSURL(string: videoUrl))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
        UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: false)
    }
    
    /// webView - 显示正文的
    lazy var webView: UIWebView = {
        let webView = UIWebView()
        webView.delegate = self
        webView.backgroundColor = COLOR_ALL_BG
        return webView
    }()

}

// MARK: - UIWebViewDelegate
extension JFWebPlayerViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        JFProgressHUD.dismiss()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error.debugDescription)
    }

}
