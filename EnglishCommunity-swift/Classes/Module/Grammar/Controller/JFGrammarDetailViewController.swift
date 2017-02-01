//
//  JFGrammarDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class JFGrammarDetailViewController: UIViewController {

    /// 播放器
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var timeObserve: AnyObject?
    
    /// 语法模型
    var grammar: JFGrammar? {
        didSet {
            guard let grammar = grammar else {
                return
            }
            
            var html = grammar.content!
            
            // 从本地加载网页模板，替换新闻主页
            let templatePath = Bundle.main.path(forResource: "www/html/article.html", ofType: nil)!
            let template = (try! String(contentsOfFile: templatePath, encoding: String.Encoding.utf8)) as NSString
            html = template.replacingOccurrences(of: "<p>mainnews</p>", with: html, options: NSString.CompareOptions.caseInsensitive, range: template.range(of: "<p>mainnews</p>"))
            let baseURL = URL(fileURLWithPath: templatePath)
            webView.loadHTMLString(html, baseURL: baseURL)
            
            playerItem = AVPlayerItem(url: URL(string: grammar.mp3!)!)
            playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            player = AVPlayer(playerItem: playerItem!)
            
            timeObserve = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (time) in
                let current = CMTimeGetSeconds(time)
                let total = CMTimeGetSeconds(self.playerItem!.duration)
                if current != 0 {
                    self.bottomView.currentTimeLabel.text = self.formatTime(current)
                    self.bottomView.totalTimeLabel.text = self.formatTime(total)
                    self.bottomView.progressView.progress = Float(current / total)
                    
                }
            }) as AnyObject?
            
            // 开始播放
            didTappedPlayButton(bottomView.playButton)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let timeObserve = timeObserve {
            player?.removeTimeObserver(timeObserve)
            self.timeObserve = nil
        }
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print("销毁")
    }

    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        title = "详情"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(webView)
        view.addSubview(bottomView)
        
        webView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - 64 - 50)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    /**
     格式化时间
     
     - parameter second: 秒数
     
     - returns: 返回格式化后的字符串
     */
    func formatTime(_ second: Float64) -> String {
        let min = Int(second / 60)
        let sec = Int(second.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            switch player!.status {
            case AVPlayerStatus.unknown:
                print("未知状态")
            case AVPlayerStatus.failed:
                print("加载失败")
            case AVPlayerStatus.readyToPlay:
                print("可以播放")
            }
        }
    }
    
    // MARK: - 懒加载
    /// 内容视图
    fileprivate lazy var webView: UIWebView = {
        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 100))
        webView.backgroundColor = UIColor.white
        return webView
    }()
    
    /// 底部播放视图
    fileprivate lazy var bottomView: JFMusicPlayerView = {
        let view = Bundle.main.loadNibNamed("JFMusicPlayerView", owner: nil, options: nil)?.last as! JFMusicPlayerView
        view.delegate = self
        return view
    }()
    
}

// MARK: - JFMusicPlayerViewDelegate
extension JFGrammarDetailViewController: JFMusicPlayerViewDelegate {
    
    /**
     点击了播放按钮
     */
    func didTappedPlayButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            player?.play()
        } else {
            player?.pause()
        }
    }
}
