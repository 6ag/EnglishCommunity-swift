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
            
            // 通用播放代码
            let playerHTML = "<iframe height=\(SCREEN_WIDTH - 44) width=\(SCREEN_HEIGHT - 20) src='http://player.youku.com/embed/\(JFVideo.getVideoId(videoUrl))' frameborder=0 'allowfullscreen'></iframe>"
            
            JFProgressHUD.show()
            webView.loadHTMLString(playerHTML, baseURL: URL(string: videoUrl))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: false)
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
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        JFProgressHUD.dismiss()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        print(error.debugDescription)
    }

}
