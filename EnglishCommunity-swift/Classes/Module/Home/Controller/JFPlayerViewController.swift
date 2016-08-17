//
//  JFPlayerViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class JFPlayerViewController: UIViewController {
    
    /// 视频列表模型数组
    var videos = [JFVideo]()
    
    /// 视频信息
    var videoInfo: JFVideoInfo? {
        didSet {
            loadVideoListData(videoInfo!.id)
        }
    }
    
    let commentCellIdentifier = "commentCellIdentifier"
    let videoCellIdentifier = "videoCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        resetPlayerManager()
        
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(player)
        view.addSubview(topBarView)
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(videoTableView)
        contentScrollView.addSubview(commentTableView)
        videoTableView.tableHeaderView = videoHeaderView
        
        player.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(view.snp_width).multipliedBy(9.0 / 16.0)
        }
        
        topBarView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(player.snp_bottom)
            make.height.equalTo(30)
        }
        
        contentScrollView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.top.equalTo(topBarView.snp_bottom)
        }
        
        videoTableView.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 30)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        commentTableView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(SCREEN_WIDTH)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(videoTableView.snp_height)
        }
        
    }
    
    /**
     重置播放器
     */
    func resetPlayerManager() {
        JFPlayerConf.allowLog = false
        JFPlayerConf.shouldAutoPlay = true
        JFPlayerConf.slowAndMirror = true
        JFPlayerConf.tintColor = UIColor.whiteColor()
        JFPlayerConf.topBarShowInCase = .Always
        JFPlayerConf.loaderType = NVActivityIndicatorType.BallRotateChase
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    deinit {
        print("播放控制器销毁")
    }
    
    /**
     加载播放列表
     
     - parameter videoInfo_id: 视频信息id
     */
    private func loadVideoListData(videoInfo_id: Int) {
        JFVideo.loadVideoList(videoInfo_id) { (videos) in
            
            guard let videos = videos else {
                return
            }
            
            self.videos = videos
            self.videoTableView.reloadData()
            self.videoTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
            self.player.playWithURL(NSURL(string: "\(BASE_URL)parse.php?url=\(videos[0].videoUrl!)")!, title: videos[0].title!)
        }
    }
    
    // MARK: - 懒加载
    /// 播放器
    lazy var player: JFPlayer = {
        let player = JFPlayer()
        player.delegate = self
        return player
    }()
    
    /// 顶部标签切换条
    lazy var topBarView: JFTopBarView = {
        let topBarView = NSBundle.mainBundle().loadNibNamed("JFTopBarView", owner: nil, options: nil).last as! JFTopBarView
        return topBarView
    }()
    
    /// 内容载体
    lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.contentSize = CGSize(width: SCREEN_WIDTH * 2, height: 1)
        contentScrollView.pagingEnabled = true
        contentScrollView.alwaysBounceHorizontal = true
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.backgroundColor = UIColor.whiteColor()
        return contentScrollView
    }()
    
    /// 视频信息和播放列表
    lazy var videoTableView: UITableView = {
        let videoTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        videoTableView.delegate = self
        videoTableView.dataSource = self
        videoTableView.backgroundColor = UIColor.whiteColor()
        videoTableView.separatorStyle = .None
        videoTableView.registerNib(UINib(nibName: "JFDetailVideoCell", bundle: nil), forCellReuseIdentifier: self.videoCellIdentifier)
        return videoTableView
    }()
    
    /// 评论
    lazy var commentTableView: UITableView = {
        let commentTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.showsVerticalScrollIndicator = false
        commentTableView.backgroundColor = UIColor.whiteColor()
        commentTableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        commentTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.commentCellIdentifier)
        return commentTableView
    }()
    
    /// 视频列表页头部视图
    lazy var videoHeaderView: JFDetailHeaderView = {
        let videoHeaderView = JFDetailHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 70))
        return videoHeaderView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == videoTableView {
            return videos.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == videoTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier) as! JFDetailVideoCell
            cell.model = videos[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == videoTableView {
            // 切换播放源
            player.prepareToDealloc()
            player.playWithURL(NSURL(string: "\(BASE_URL)parse.php?url=\(videos[indexPath.row].videoUrl!)")!, title: videos[indexPath.row].title!)
        } else {
            
        }
    }
    
}

// MARK: - JFPlayerDelegate
extension JFPlayerViewController: JFPlayerDelegate {
    
    /**
     在不是全屏的状态点了返回按钮
     */
    func didTappedBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     播放器状态改变监听
     
     - parameter player: 播放器
     - parameter state:  状态
     */
    func player(player: JFPlayer, playerStateChanged state: JFPlayerState) {
        switch state {
        case .Unknown:
            print("未知")
        case .Playable:
            print("可以播放")
        case .PlaythroughOK:
            print("从头到尾播放OK")
        case .Stalled:
            print("熄火")
        case .PlaybackEnded:
            print("播放正常结束")
        case .PlaybackError:
            print("播放错误")
            JFProgressHUD.showInfoWithStatus("解码失败，请稍后重试")
        case .UserExited:
            print("用户退出")
        case .Stopped:
            print("停止")
        case .Paused:
            print("暂停")
        case .Playing:
            print("正在播放")
        case .Interrupted:
            print("中断")
        case .SeekingForward:
            print("快退")
        case .SeekingBackward:
            print("快进")
        case .NotSetURL:
            print("未设置URL")
        case .Buffering:
            print("缓冲中")
        case .BufferFinished:
            print("缓冲完毕")
        }

    }
}
