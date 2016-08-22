//
//  JFAboutMeViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFAboutMeViewController: UIViewController {

    override func loadView() {
        view = UIWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = COLOR_ALL_BG
        
        let html = "<!doctype html>" +
        "<head>" +
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>" +
        "<style type=\"text/css\">" +
        ".container {background: #FFFFFF;}" +
        ".content {width: 100%;font-size: 16px;}" +
        "p {margin: 0px 0px 5px 0px}" +
        "</style>" +
        "</head>" +
        "<body class=\"container\">" +
        "<div class=\"content\">" +
        "<p>本应用所有学习资源来自网络收集整理，且不收取任何视频观看费用，由观看或下载视频所造成的流量费与本应用无关。</p>" +
        "<p>您有任何事情，都可以通过以下方式联系到我。包括且不限于求学习资料、学习交流等。</p>" +
        "<p>QQ群：576706713</p>" +
        "<p>邮箱：admin@6ag.cn</p>" +
        "</div>" +
        "</body>" +
        "</html>"
        
        let webView = (view as! UIWebView)
        webView.dataDetectorTypes = .None
        webView.loadHTMLString(html, baseURL: nil)
    }
}
