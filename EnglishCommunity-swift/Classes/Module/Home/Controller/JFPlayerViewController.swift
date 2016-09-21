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
import Firebase
import GoogleMobileAds

class JFPlayerViewController: UIViewController {
    
    /// 当前页码
    var page: Int = 1
    
    /// 当前播放的下标
    var currentIndex = 0
    
    /// 准备列表
    var comments = [JFComment]()
    
    /// 视频列表模型数组
    var videos = [JFVideo]()
    
    /// 即将回复的评论
    var revertComment: JFComment?
    
    /// 评论重用标识
    let commentCellIdentifier = "commentCellIdentifier"
    
    /// 视频列表评论标识
    let videoCellIdentifier = "videoCellIdentifier"
    
    // 插页广告
    var interstitial: GADInterstitial!
    
    /// 视频播放节点 默认播放节点从全局获取
    var nodeIndex = (PLAY_NODE == "app" ? 0 : 1) {
        didSet (oldValue) {
            if nodeIndex != oldValue {
                playVideoOfNodeIndex()
            }
        }
    }
    
    /// 视频信息
    var videoInfo: JFVideoInfo? {
        didSet {
            // 封面
            if let cover = videoInfo?.cover {
                playerPlaceholderImageView.yy_imageURL = NSURL(string: cover)
            }
            
            // 加载视频播放列表
            loadVideoListData(videoInfo!.id)
            
            // 加载评论数据
            updateData("video_info", page: 1, method: 0, source_id: videoInfo!.id)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 重置播放器
        resetPlayerManager()
        
        prepareUI()
        
        // 创建并加载插页广告
        interstitial = createAndLoadInterstitial()
        
        JFDownloadManager.shareManager.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        player.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        player.pause()
    }
    
    deinit {
        print("播放控制器销毁")
        JFDownloadManager.shareManager.delegate = nil
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
        view.addSubview(playerPlaceholderImageView)
        view.addSubview(topBarView)
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(videoTableView)
        contentScrollView.addSubview(commentTableView)
        view.addSubview(bottomBarView)
        view.addSubview(player)
        bottomBarView.joinCollectionButton.setTitle(videoInfo?.collected == 1 ? "取消收藏" : "收藏课程", forState: .Normal)
        view.addSubview(multiTextView)
        
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
        
        if iPhoneModel.getCurrentModel() == iPhoneModel.iPad {
            // 播放器底部占位图
            playerPlaceholderImageView.snp_makeConstraints { (make) in
                make.top.equalTo(64)
                make.left.right.equalTo(0)
                make.height.equalTo(view.snp_width).multipliedBy(3.0 / 4.0)
            }
            
            // 播放器
            player.snp_makeConstraints { (make) in
                make.top.equalTo(view.snp_top).offset(64)
                make.left.right.equalTo(0)
                make.height.equalTo(player.snp_width).multipliedBy(3.0 / 4.0)
            }
            
            // 切换视频和评论的toolBar
            topBarView.snp_makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.top.equalTo(navigationBarView.snp_bottom).offset(SCREEN_WIDTH * (3.0 / 4.0))
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
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (3.0 / 4.0) - 118)
                make.width.equalTo(SCREEN_WIDTH)
            }
            
            // 评论列表
            commentTableView.snp_makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(SCREEN_WIDTH)
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (3.0 / 4.0) - 150)
            }
        } else {
            // 播放器底部占位图
            playerPlaceholderImageView.snp_makeConstraints { (make) in
                make.top.equalTo(64)
                make.left.right.equalTo(0)
                make.height.equalTo(view.snp_width).multipliedBy(9.0 / 16.0)
            }
            
            // 播放器
            player.snp_makeConstraints { (make) in
                make.top.equalTo(view.snp_top).offset(64)
                make.left.right.equalTo(0)
                make.height.equalTo(player.snp_width).multipliedBy(9.0 / 16.0)
            }
            
            // 切换视频和评论的toolBar
            topBarView.snp_makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.top.equalTo(navigationBarView.snp_bottom).offset(SCREEN_WIDTH * (9.0 / 16.0))
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
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 118)
                make.width.equalTo(SCREEN_WIDTH)
            }
            
            // 评论列表
            commentTableView.snp_makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(SCREEN_WIDTH)
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 150)
            }
        }
        
        // 底部工具条
        bottomBarView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(49)
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
    
    /**
     解析并播放视频
     
     - parameter videoUrl: 优酷地址
     - parameter title:    视频标题
     */
    private func playVideo(video: JFVideo) {
        
        // 满足条件才显示广告
        if JFAccountModel.shareAccount()?.adDsabled != 1 {
            // 弹出插页广告
            if interstitial.isReady {
                interstitial.presentFromRootViewController(self)
                return
            }
        }
        
        if nodeIndex == 0 { // 节点0 使用m3u8方式播放
            player.userInteractionEnabled = true
            
            if NSUserDefaults.standardUserDefaults().boolForKey(KEY_ALLOW_CELLULAR_PLAY) || JFNetworkTools.shareNetworkTool.getCurrentNetworkState() <= 1 {
                
                // 判断播放本地还是网络
                if video.state == VideoState.AlreadyDownload {
                    let videoVid = JFVideo.getVideoId(video.videoUrl ?? "")
                    if let url = NSURL(string: "http://localhost:8080/Documents/DownloadVideos/\(videoVid)/movie.m3u8") {
                        self.player.playWithURL(url, title: video.title!)
                        print(url)
                    }
                } else {
                    JFVideo.parseVideoUrl(video.videoUrl ?? "") { (url) in
                        guard let url = url else {
                            JFProgressHUD.showInfoWithStatus("播放失败，请更换节点")
                            return
                        }
                        self.player.playWithURL(NSURL(string: url)!, title: video.title ?? "")
                    }
                }
            } else {
                let alertC = UIAlertController(title: "温馨提示", message: "当前无可用WiFi，继续播放将会扣流量哦", preferredStyle: UIAlertControllerStyle.Alert)
                let continuePlay = UIAlertAction(title: "继续播放", style: UIAlertActionStyle.Destructive, handler: { (acion) in
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: KEY_ALLOW_CELLULAR_PLAY)
                    JFVideo.parseVideoUrl(video.videoUrl ?? "") { (url) in
                        guard let url = url else {
                            JFProgressHUD.showInfoWithStatus("播放失败，请更换节点")
                            return
                        }
                        self.player.playWithURL(NSURL(string: url)!, title: video.title ?? "")
                    }
                })
                let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (acion) in })
                alertC.addAction(continuePlay)
                alertC.addAction(cancel)
                presentViewController(alertC, animated: true, completion: nil)
            }
            
        } else if nodeIndex == 1 { // 节点1 使用网页播放
            
            player.userInteractionEnabled = false
            // web节点，使用web播放器播放
            player.prepareToDealloc()
            let webPlayerVc = JFWebPlayerViewController()
            webPlayerVc.video = video
            navigationController?.pushViewController(webPlayerVc, animated: true)
        }
        
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
            self.videoTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
            self.playVideo(videos[0])
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
     更新评论数据
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
     根据节点和视频模型播放视频
     */
    private func playVideoOfNodeIndex() {
        
        guard let index = videoTableView.indexPathForSelectedRow?.row else {
            return
        }
        
        // 获取选中的cell的模型
        let video = videos[index]
        playVideo(video)
    }
    
    /**
     点击了返回按钮
     */
    @objc private func didTappedBackButton() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - 懒加载
    /// 播放器位置占位图
    lazy var playerPlaceholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "player_placeholder_bg"))
        return imageView
    }()
    
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
    
    // 播放器
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
        contentScrollView.backgroundColor = COLOR_ALL_BG
        return contentScrollView
    }()
    
    /// 视频信息和播放列表
    lazy var videoTableView: UITableView = {
        let videoTableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        videoTableView.delegate = self
        videoTableView.dataSource = self
        videoTableView.backgroundColor = COLOR_ALL_BG
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
        commentTableView.backgroundColor = COLOR_ALL_BG
        commentTableView.separatorStyle = .None
        commentTableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentCellIdentifier)
        commentTableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        return commentTableView
    }()
    
    /// 底部工具条
    lazy var bottomBarView: JFDetailBottomBarView = {
        let bottomBarView = NSBundle.mainBundle().loadNibNamed("JFDetailBottomBarView", owner: nil, options: nil).last as! JFDetailBottomBarView
        bottomBarView.delegate = self
        return bottomBarView
    }()
    
    /// 评论文本框
    lazy var multiTextView: JFMultiTextView = {
        let textView = JFMultiTextView()
        textView.haveNavigationBar = false
        textView.delegate = self
        textView.alpha = 0
        return textView
    }()
    
    /// 选择节点视图
    lazy var selectNodeView: JFSelectNodeView = {
        let view = NSBundle.mainBundle().loadNibNamed("JFSelectNodeView", owner: nil, options: nil).last as! JFSelectNodeView
        view.delegate = self
        return view
    }()
    
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
            // 自动播放下一节
            if currentIndex < videos.count - 1 {
                currentIndex += 1
                videoTableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
                tableView(videoTableView, didSelectRowAtIndexPath: NSIndexPath(forRow: currentIndex, inSection: 0))
            }
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
            self.player.snp_updateConstraints(closure: { (make) in
                make.top.equalTo(view.snp_top).offset(0)
            })
            print("全屏")
        case .CompactScreen:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            self.player.snp_updateConstraints(closure: { (make) in
                make.top.equalTo(view.snp_top).offset(64)
            })
            print("竖屏")
        }
        
    }
}

// MARK: - GADInterstitialDelegate 插页广告相关方法
extension JFPlayerViewController: GADInterstitialDelegate {
    
    /**
     当插页广告dismiss后初始化插页广告对象
     */
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        playVideoOfNodeIndex()
        interstitial = createAndLoadInterstitial()
    }
    
    /**
     初始化插页广告
     
     - returns: 插页广告对象
     */
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: INTERSTITIAL_UNIT_ID)
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        return interstitial
    }
    
}

// MARK: - 屏幕旋转
extension JFPlayerViewController  {
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation == UIInterfaceOrientation.Portrait || toInterfaceOrientation == UIInterfaceOrientation.PortraitUpsideDown {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }
    }
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
                let cell = tableView.dequeueReusableCellWithIdentifier(commentCellIdentifier) as! JFCommentCell
                let height = cell.getRowHeight(comment)
                comment.rowHeight = height
            }
            return comment.rowHeight
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == videoTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier) as! JFDetailVideoCell
            cell.delegate = self
            cell.model = videos[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(commentCellIdentifier) as! JFCommentCell
            cell.comment = comments[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == videoTableView {
            
            // 当前播放的下标
            currentIndex = indexPath.row
            
            // 选中
            for video in videos {
                video.videoListSelected = false
            }
            videos[indexPath.row].videoListSelected = true
            
            player.prepareToDealloc()
            
            if JFAccountModel.isLogin() || indexPath.row == 0 {
                self.playVideo(videos[indexPath.row])
            } else {
                let alertController = UIAlertController(title: "您未登录", message: "为了营造一个良好的学习社区,您需要登录后才能继续观看更多视频哦！", preferredStyle: UIAlertControllerStyle.Alert)
                let confirm = UIAlertAction(title: "确定登录", style: UIAlertActionStyle.Destructive, handler: { (action) in
                    isLogin(self)
                })
                let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in })
                alertController.addAction(confirm)
                alertController.addAction(cancel)
                presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            // 即将回复的评论
            revertComment = comments[indexPath.row]
            
            // 弹出键盘并获得第一响应者
            multiTextView.expansion()
            multiTextView.placeholderString = "@\(revertComment!.author!.nickname!) "
        }
    }
    
}

// MARK: - JFCommentCellDelegate
extension JFPlayerViewController: JFCommentCellDelegate {
    
    func commentCell(cell: JFCommentCell, didTappedAtUser nickname: String, sequence: Int) {
        guard let atUser = cell.comment?.extendsAuthor else {
            return
        }
        
        if atUser.nickname == nickname {
            let otherUser = JFOtherUserViewController()
            otherUser.userId = atUser.id
            navigationController?.pushViewController(otherUser, animated: true)
        }
    }
    
    func commentCell(cell: JFCommentCell, didTappedAvatarButton button: UIButton) {
        guard let author = cell.comment?.author else {
            return
        }
        
        let otherUser = JFOtherUserViewController()
        otherUser.userId = author.id
        navigationController?.pushViewController(otherUser, animated: true)
    }
}

// MARK: - JFTopBarViewDelegate
extension JFPlayerViewController: JFTopBarViewDelegate {
    
    func didSelectedMenuButton() {
        contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        bottomBarView.alpha = 1
        multiTextView.alpha = 0
    }
    
    func didSelectedCommentButton() {
        contentScrollView.setContentOffset(CGPoint(x: SCREEN_WIDTH, y: 0), animated: true)
        bottomBarView.alpha = 0
        multiTextView.alpha = 1
    }
}

// MARK: - UIScrollViewDelegate
extension JFPlayerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x >= SCREEN_WIDTH) && scrollView == contentScrollView {
            topBarView.didTappedCommentButton()
            bottomBarView.alpha = 0
            multiTextView.alpha = 1
        } else if scrollView == contentScrollView {
            topBarView.didTappedMenuButton()
            bottomBarView.alpha = 1
            multiTextView.alpha = 0
        }
    }
}

// MARK: - JFDetailBottomBarView
extension JFPlayerViewController: JFDetailBottomBarViewDelegate {
    
    /**
     切换线路
     */
    func didTappedChangeLineButton(button: UIButton) {
        selectNodeView.show()
    }
    
    /**
     下载视频
     */
    func didTappedDownloadButton(button: UIButton) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey(KEY_ALLOW_CELLULAR_DOWNLOAD) || JFNetworkTools.shareNetworkTool.getCurrentNetworkState() <= 1 {
            let videoDownloadVc = JFVideoDownloadViewController()
            videoDownloadVc.videos = videos
            videoDownloadVc.videoInfo = videoInfo
            presentViewController(videoDownloadVc, animated: true, completion: nil)
        } else {
            let alertC = UIAlertController(title: "温馨提示", message: "当前无可用WiFi，继续下载会扣流量哦", preferredStyle: UIAlertControllerStyle.Alert)
            let continuePlay = UIAlertAction(title: "继续下载", style: UIAlertActionStyle.Destructive, handler: { (acion) in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: KEY_ALLOW_CELLULAR_DOWNLOAD)
                let videoDownloadVc = JFVideoDownloadViewController()
                videoDownloadVc.videos = self.videos
                videoDownloadVc.videoInfo = self.videoInfo
                self.presentViewController(videoDownloadVc, animated: true, completion: nil)
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (acion) in })
            alertC.addAction(continuePlay)
            alertC.addAction(cancel)
            presentViewController(alertC, animated: true, completion: nil)
        }
        
    }
    
    /**
     分享
     */
    func didTappedShareButton(button: UIButton) {
        
        let shareParames = NSMutableDictionary()
        shareParames.SSDKSetupShareParamsByText("最棒的自学英语社区，海量免费英语视频，涵盖音标、单词、语法、口语、听力、阅读、作文等内容！你还等什么呢？马上一起学习吧！",
                                                images : UIImage(named: "share"),
                                                url : NSURL(string: "https://itunes.apple.com/cn/app/id\(APPLE_ID)"),
                                                title : videoInfo!.title!,
                                                type : SSDKContentType.Auto)
        let items = [
            SSDKPlatformType.TypeQQ.rawValue,
            SSDKPlatformType.TypeWechat.rawValue,
            SSDKPlatformType.TypeSinaWeibo.rawValue
        ]
        
        ShareSDK.showShareActionSheet(nil, items: items, shareParams: shareParames) { (state : SSDKResponseState, platform: SSDKPlatformType, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!, end: Bool) in
            switch state {
            case SSDKResponseState.Success:
                print("分享成功")
            case SSDKResponseState.Fail:
                print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:
                print("取消分享")
            default:
                break
            }
        }
        
    }
    
    /**
     加入收藏
     */
    func didTappedJoinCollectionButton(button: UIButton) {
        if isLogin(self) {
            JFNetworkTools.shareNetworkTool.addOrCancelCollection(videoInfo!.id) { (success, result, error) in
                guard let result = result where result["status"] == "success" else {
                    return
                }
                JFProgressHUD.showInfoWithStatus("操作成功")
                if result["result"]["type"].stringValue == "add" {
                    // 赞
                    self.bottomBarView.joinCollectionButton.setTitle("取消收藏", forState: .Normal)
                } else {
                    // 取消赞
                    self.bottomBarView.joinCollectionButton.setTitle("收藏课程", forState: .Normal)
                }
            }
        }
        
    }
}

// MARK: - JFMultiTextViewDelegate
extension JFPlayerViewController: JFMultiTextViewDelegate {
    
    /**
     点击了键盘发送按钮
     
     - parameter text: 输入的内容
     */
    func didTappedSendButton(text: String) {
        
        let pid = revertComment?.id ?? 0
        revertComment = nil
        
        if isLogin(self) {
            JFComment.publishComment("video_info", sourceId: videoInfo!.id, content: text, pid: pid, finished: { (success) in
                if success {
                    self.updateData("video_info", page: 1, method: 0, source_id: self.videoInfo!.id)
                }
            })
        }
        
    }
}

// MARK: - JFSelectNodeViewDelegate
extension JFPlayerViewController: JFSelectNodeViewDelegate {
    
    /**
     选择了app节点
     */
    func didTappedAppButton(button: UIButton) {
        nodeIndex = 0
    }
    
    /**
     选择了web节点
     */
    func didTappedWebButton(button: UIButton) {
        nodeIndex = 1
    }
}

// MARK: - JFDownloadManagerDelegate
extension JFPlayerViewController: JFDownloadManagerDelegate {
    
    /**
     下载视频失败
     
     - parameter videoVid:    视频的vid
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadFailWithVideoId(videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(0, videoInfoId: videoInfoId, index: index, state: VideoState.NoDownload)
    }
    
    /**
     解析视频视频 - 不是有效的m3u8地址
     
     - parameter videoVid:    视频的vid
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadParseFailWithVideoId(videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(0, videoInfoId: videoInfoId, index: index, state: VideoState.NoDownload)
    }
    
    /**
     下载视频完成
     
     - parameter videoVid:    视频的vid
     - parameter path:        视频下载完成后的本地路径
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadFinishWithVideoId(videoVid: String, localPath path: String, videoInfoId: Int, index: Int) {
        videoStateChange(1.0, videoInfoId: videoInfoId, index: index, state: VideoState.AlreadyDownload)
    }
    
    /**
     正在下载 更新进度
     
     - parameter progress:    下载进度 0.0 - 1.0
     - parameter videoVid:    视频的vid
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadProgress(progress: CGFloat, withVideoVid videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(progress, videoInfoId: videoInfoId, index: index, state: VideoState.Downloading)
    }
    
    /**
     下载状态发生改变
     
     - parameter progress:    下载进度 0.0 - 1.0
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     - parameter state:       视频当前的状态
     */
    func videoStateChange(progress: CGFloat, videoInfoId: Int, index: Int, state: VideoState) {
        if videoInfoId == videoInfo?.id ?? 0 && index <= videos.count - 1 {
            let video = videos[index]
            video.state = state
            video.progress = progress
            
            // 防止cell还没有缓存
            if let cell = videoTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? JFDetailVideoCell  {
                cell.model = video
            }
        }
    }
}

// MARK: - JFDetailVideoCellDelegate
extension JFPlayerViewController: JFDetailVideoCellDelegate {
    
    /**
     点击了下载按钮
     
     - parameter cell:   所在的cell
     - parameter button: 被点击的按钮
     */
    func didTappedDownloadButton(cell: JFDetailVideoCell, button: UIButton) {
        
        if !JFAccountModel.isLogin() {
            let alertC = UIAlertController(title: "只有注册用户才能操作哦", message: "登录后可以无限制观看和下载视频教程哦", preferredStyle: UIAlertControllerStyle.Alert)
            let confirm = UIAlertAction(title: "登录", style: UIAlertActionStyle.Destructive, handler: { (action) in
                isLogin(self)
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in })
            alertC.addAction(confirm)
            alertC.addAction(cancel)
            presentViewController(alertC, animated: true, completion: { })
            return
        }
        
        let indexPath = videoTableView.indexPathForCell(cell)!
        let video = videos[indexPath.row]
        
        switch video.state {
        case VideoState.NoDownload:
            
            video.state = VideoState.Downloading
            JFDownloadManager.shareManager.startDownloadVideo(videoInfo?.id ?? 0, index: indexPath.row, videoUrl: video.videoUrl ?? "")
            
        case VideoState.AlreadyDownload:
            
            if video.videoListSelected {
                JFProgressHUD.showInfoWithStatus("您正在播放这个视频哦")
                return
            }
            
            let alertC = UIAlertController(title: "确认要删除这节视频吗", message: "删除缓存后，可以节省手机磁盘空间，但重新缓存又得WiFi哦", preferredStyle: UIAlertControllerStyle.Alert)
            let confirm = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.Destructive, handler: { (action) in
                video.state = VideoState.NoDownload
                let videoVid = JFVideo.getVideoId(video.videoUrl!)
                
                // 从数据库移除
                JFDALManager.shareManager.removeVideo(videoVid, finished: { (success) in
                    if success {
                        // 从本地文件移除
                        let path = "\(DOWNLOAD_PATH)\(videoVid)"
                        let fileManager = NSFileManager.defaultManager()
                        if fileManager.fileExistsAtPath(path) {
                            do {
                                try fileManager.removeItemAtPath(path)
                                print("删除成功")
                                self.videoStateChange(0, videoInfoId: self.videoInfo?.id ?? 0, index: indexPath.row, state: VideoState.NoDownload)
                            } catch {
                                print("删除失败")
                            }
                        }
                    }
                })
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in })
            alertC.addAction(confirm)
            alertC.addAction(cancel)
            presentViewController(alertC, animated: true, completion: { })
            
        case VideoState.Downloading:
            
            video.state = VideoState.NoDownload
            videoStateChange(0, videoInfoId: videoInfo?.id ?? 0, index: indexPath.row, state: VideoState.NoDownload)
            JFDownloadManager.shareManager.cancelDownloadVideo(video.videoUrl!)
            
        }
        
    }
}
