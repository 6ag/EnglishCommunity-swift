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
import YYWebImage

class JFPlayerViewController: UIViewController {
    
    /// 当前页码
    var page: Int = 1
    
    /// 准备列表
    var comments = [JFComment]()
    
    /// 视频列表模型数组
    var videos = [JFVideo]()
    
    /// 视频信息
    var videoInfo: JFVideoInfo? {
        didSet {
            loadVideoListData(videoInfo!.id)
            updateData("video_info", page: page, method: 1, source_id: videoInfo!.id)
        }
    }
    
    let commentCellIdentifier = "commentCellIdentifier"
    let videoCellIdentifier = "videoCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        commentTableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        
        // 重置播放器
        resetPlayerManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        player.prepareToDealloc()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = COLOR_ALL_BG
        videoTableView.tableHeaderView = videoHeaderView
        
        view.addSubview(navigationBarView)
        view.addSubview(topBarView)
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(videoTableView)
        contentScrollView.addSubview(commentTableView)
        view.addSubview(bottomBarView)
        view.addSubview(player)
        
        // 自定义导航栏
        navigationBarView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(64)
        }
        
        // 返回按钮
        backButton.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.bottom.equalTo(0)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        // 标题
        titleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView)
            make.centerY.equalTo(navigationBarView).offset(10)
        }
        
        // 播放器
        player.snp_makeConstraints { (make) in
            make.top.equalTo(64)
            make.left.right.equalTo(0)
            make.height.equalTo(view.snp_width).multipliedBy(9.0 / 16.0)
        }
        
        // 切换视频和评论的toolBar
        topBarView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(player.snp_bottom)
            make.height.equalTo(40.5)
        }
        
        // 视频列表和评论列表的载体
        contentScrollView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.top.equalTo(topBarView.snp_bottom)
        }
        
        // 视频播放列表
        videoTableView.snp_makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 110)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        // 评论列表
        commentTableView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(SCREEN_WIDTH)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 64)
        }
        
        // 底部工具条
        bottomBarView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(49)
        }
        
    }
    
    deinit {
        print("播放控制器销毁")
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
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData("video_info", page: page, method: 1, source_id: videoInfo!.id)
    }
    
    /**
     更新数据
     */
    private func updateData(type: String, page: Int, method: Int, source_id: Int) {
        
        JFComment.loadCommentList(page, type: type, source_id: source_id) { (comments) in
            
            self.commentTableView.mj_footer.endRefreshing()
            
            guard let comments = comments else {
                self.commentTableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.comments = comments
            } else {
                self.comments += comments
            }
            
            self.commentTableView.reloadData()
        }
        
    }
    
    /**
     点击了返回按钮
     */
    @objc private func didTappedBackButton() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - 懒加载
    /// 自定义导航栏
    lazy var navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("ffffff")
        view.addSubview(self.titleLabel)
        view.addSubview(self.backButton)
        return view
    }()
    
    /// 控制器标题
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "课程详情"
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.colorWithHexString("24262F")
        return label
    }()
    
    /// 返回按钮
    lazy var backButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.addTarget(self, action: #selector(didTappedBackButton), forControlEvents: .TouchUpInside)
        button.setImage(UIImage(named: "navigation_back_normal"), forState: .Normal)
        return button
    }()
    
    /// 播放器
    lazy var player: JFPlayer = {
        let player = JFPlayer()
        player.delegate = self
        return player
    }()
    
    /// 顶部标签切换条
    lazy var topBarView: JFTopBarView = {
        let topBarView = NSBundle.mainBundle().loadNibNamed("JFTopBarView", owner: nil, options: nil).last as! JFTopBarView
        topBarView.delegate = self
        return topBarView
    }()
    
    /// 视频列表页头部视图
    lazy var videoHeaderView: JFDetailHeaderView = {
        let videoHeaderView = JFDetailHeaderView()
        videoHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: 60)
        videoHeaderView.videoInfo = self.videoInfo
        return videoHeaderView
    }()
    
    /// 内容载体
    lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.contentSize = CGSize(width: SCREEN_WIDTH * 2, height: 0)
        contentScrollView.pagingEnabled = true
        contentScrollView.alwaysBounceHorizontal = true
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.delegate = self
        contentScrollView.backgroundColor = UIColor.whiteColor()
        return contentScrollView
    }()
    
    /// 视频信息和播放列表
    lazy var videoTableView: UITableView = {
        let videoTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
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
        commentTableView.separatorStyle = .None
        commentTableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentCellIdentifier)
        return commentTableView
    }()
    
    /// 底部工具条
    lazy var bottomBarView: JFDetailBottomBarView = {
        let bottomBarView = NSBundle.mainBundle().loadNibNamed("JFDetailBottomBarView", owner: nil, options: nil).last as! JFDetailBottomBarView
        return bottomBarView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == videoTableView {
            return videos.count
        } else {
            return comments.count
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == videoTableView {
            return 10
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == videoTableView {
            let sectionView = UIView()
            sectionView.backgroundColor = UIColor.colorWithHexString("f7f7f7")
            return sectionView
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == videoTableView {
            return 44
        } else {
            let comment = comments[indexPath.row]
            if Int(comment.rowHeight) == 0 {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! JFCommentCell
                let height = cell.getRowHeight(comment)
                comment.rowHeight = height
            }
            return comment.rowHeight
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == videoTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier) as! JFDetailVideoCell
            cell.model = videos[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier) as! JFCommentCell
            cell.comment = comments[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView == videoTableView {
            player.prepareToDealloc()
            player.playWithURL(NSURL(string: "\(BASE_URL)parse.php?url=\(videos[indexPath.row].videoUrl!)")!, title: videos[indexPath.row].title!)
        } else {
            
        }
    }
    
}

// MARK: - JFTopBarViewDelegate
extension JFPlayerViewController: JFTopBarViewDelegate {
    
    func didSelectedMenuButton() {
        contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func didSelectedCommentButton() {
        contentScrollView.setContentOffset(CGPoint(x: SCREEN_WIDTH, y: 0), animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension JFPlayerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x >= SCREEN_WIDTH) {
            topBarView.didTappedCommentButton()
        } else {
            topBarView.didTappedMenuButton()
        }
    }
}

// MARK: - JFPlayerDelegate
extension JFPlayerViewController: JFPlayerDelegate {
    
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
        case .FullScreen:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            player.snp_updateConstraints(closure: { (make) in
                make.top.equalTo(0)
            })
            print("全屏")
        case .CompactScreen:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            player.snp_updateConstraints(closure: { (make) in
                make.top.equalTo(64)
            })
            print("竖屏")
        }

    }
}
