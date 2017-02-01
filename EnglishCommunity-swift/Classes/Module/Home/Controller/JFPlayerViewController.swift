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
    
    /// 准备列表
    var comments = [JFComment]()
    
    /// 视频列表模型数组
    var videos = [JFVideo]()
    
    /// 当前播放的下标
    var currentIndex = 0
    
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
                playerPlaceholderImageView.yy_imageURL = URL(string: cover)
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
        
        // 屏幕旋转监听
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChanged(_:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        JFDownloadManager.shareManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        player.autoPlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        player.pause(allowAutoPlay: true)
    }
    
    deinit {
        print("播放控制器销毁")
        JFDownloadManager.shareManager.delegate = nil
        player.prepareToDealloc()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
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
        bottomBarView.joinCollectionButton.setTitle(videoInfo?.collected == 1 ? "取消收藏" : "收藏课程", for: UIControlState())
        view.addSubview(multiTextView)
        
        // 自定义导航栏
        navigationBarView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(64)
        }
        
        // 返回按钮
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.bottom.equalTo(0)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        // 标题
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(navigationBarView)
            make.centerY.equalTo(navigationBarView).offset(10)
        }
        
        if iPhoneModel.getCurrentModel() == iPhoneModel.iPad {
            // 播放器底部占位图
            playerPlaceholderImageView.snp.makeConstraints { (make) in
                make.top.equalTo(64)
                make.left.right.equalTo(0)
                make.height.equalTo(view.snp.width).multipliedBy(3.0 / 4.0)
            }
            
            // 播放器
            player.snp.makeConstraints { (make) in
                make.top.equalTo(view.snp.top).offset(64)
                make.left.right.equalTo(0)
                make.height.equalTo(player.snp.width).multipliedBy(3.0 / 4.0)
            }
            
            // 切换视频和评论的toolBar
            topBarView.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.top.equalTo(navigationBarView.snp.bottom).offset(SCREEN_WIDTH * (3.0 / 4.0))
                make.height.equalTo(40.5)
            }
            
            // 视频列表和评论列表的载体
            contentScrollView.snp.makeConstraints { (make) in
                make.left.bottom.right.equalTo(0)
                make.top.equalTo(topBarView.snp.bottom)
            }
            
            // 视频播放列表
            videoTableView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (3.0 / 4.0) - 118)
                make.width.equalTo(SCREEN_WIDTH)
            }
            
            // 评论列表
            commentTableView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(SCREEN_WIDTH)
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (3.0 / 4.0) - 150)
            }
        } else {
            // 播放器底部占位图
            playerPlaceholderImageView.snp.makeConstraints { (make) in
                make.top.equalTo(64)
                make.left.right.equalTo(0)
                make.height.equalTo(view.snp.width).multipliedBy(9.0 / 16.0)
            }
            
            // 播放器
            player.snp.makeConstraints { (make) in
                make.top.equalTo(view.snp.top).offset(64)
                make.left.right.equalTo(0)
                make.height.equalTo(player.snp.width).multipliedBy(9.0 / 16.0)
            }
            
            // 切换视频和评论的toolBar
            topBarView.snp.makeConstraints { (make) in
                make.left.right.equalTo(0)
                make.top.equalTo(navigationBarView.snp.bottom).offset(SCREEN_WIDTH * (9.0 / 16.0))
                make.height.equalTo(40.5)
            }
            
            // 视频列表和评论列表的载体
            contentScrollView.snp.makeConstraints { (make) in
                make.left.bottom.right.equalTo(0)
                make.top.equalTo(topBarView.snp.bottom)
            }
            
            // 视频播放列表
            videoTableView.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.top.equalTo(0)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 118)
                make.width.equalTo(SCREEN_WIDTH)
            }
            
            // 评论列表
            commentTableView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(SCREEN_WIDTH)
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(SCREEN_HEIGHT - SCREEN_WIDTH * (9.0 / 16.0) - 150)
            }
        }
        
        // 底部工具条
        bottomBarView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(49)
        }
        
    }
    
    /**
     重置播放器
     */
    func resetPlayerManager() {
        BMPlayerConf.allowLog = false
        BMPlayerConf.shouldAutoPlay = true
        BMPlayerConf.tintColor = UIColor.white
        BMPlayerConf.topBarShowInCase = .horizantalOnly
        BMPlayerConf.loaderType = NVActivityIndicatorType.ballRotateChase
    }
    
    /**
     播放视频
     
     - parameter video: 视频模型
     */
    fileprivate func playVideo(_ video: JFVideo) {
        
        // 满足条件才显示广告
        if JFAccountModel.shareAccount()?.adDsabled != 1 {
            // 弹出插页广告
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
                return
            }
        }
        
        if video.state == VideoState.alreadyDownload {
            player.isUserInteractionEnabled = true
            let videoVid = JFVideo.getVideoId(video.videoUrl ?? "")
            if let url = URL(string: "http://localhost:8080/Documents/DownloadVideos/\(videoVid)/movie.m3u8") {
                self.player.playWithURL(url, title: video.title!)
                print(url)
            }
        } else {
            if UserDefaults.standard.bool(forKey: KEY_ALLOW_CELLULAR_PLAY) || JFNetworkTools.shareNetworkTool.getCurrentNetworkState() <= 1 {
                playViewByNode(video)
            } else {
                let alertC = UIAlertController(title: "温馨提示", message: "当前无可用WiFi，继续播放将会扣流量哦", preferredStyle: UIAlertControllerStyle.alert)
                let continuePlay = UIAlertAction(title: "继续播放", style: UIAlertActionStyle.destructive, handler: { (acion) in
                    UserDefaults.standard.set(true, forKey: KEY_ALLOW_CELLULAR_PLAY)
                    self.playViewByNode(video)
                })
                let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (acion) in })
                alertC.addAction(continuePlay)
                alertC.addAction(cancel)
                present(alertC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    /**
     分节点播放视频
     
     - parameter video: 视频模型
     */
    fileprivate func playViewByNode(_ video: JFVideo) {
        if nodeIndex == 0 { // 节点0 使用m3u8方式播放
            player.isUserInteractionEnabled = true
            
            JFVideo.parseVideoUrl(video.videoUrl ?? "") { (url) in
                guard let url = url else {
                    JFProgressHUD.showInfoWithStatus("播放失败，请更换节点")
                    return
                }
                self.player.playWithURL(URL(string: url)!, title: video.title ?? "")
            }
            
        } else if nodeIndex == 1 { // 节点1 使用网页播放
            
            player.isUserInteractionEnabled = false
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
    fileprivate func loadVideoListData(_ videoInfo_id: Int) {
        
        JFVideo.loadVideoList(videoInfo_id) { (videos) in
            
            guard let videos = videos else {
                return
            }
            
            self.videos = videos
            self.videoTableView.reloadData()
            self.videoTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            self.playVideo(videos[0])
        }
    }
    
    /**
     上拉加载更多
     */
    @objc fileprivate func pullUpMoreData() {
        page += 1
        updateData("video_info", page: page, method: 1, source_id: videoInfo!.id)
    }
    
    /**
     更新评论数据
     */
    fileprivate func updateData(_ type: String, page: Int, method: Int, source_id: Int) {
        
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
    fileprivate func playVideoOfNodeIndex() {
        
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
    @objc fileprivate func didTappedBackButton() {
        _ = navigationController?.popViewController(animated: true)
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
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.colorWithHexString("24262F")
        return label
    }()
    
    /// 返回按钮
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTappedBackButton), for: .touchUpInside)
        button.setImage(UIImage(named: "navigation_back_normal"), for: UIControlState())
        return button
    }()
    
    // 播放器
    lazy var player: BMPlayer = {
        let player = BMPlayer()
        player.videoGravity = "AVLayerVideoGravityResizeAspectFill"
        player.delegate = self
        return player
    }()
    
    /// 顶部标签切换条
    lazy var topBarView: JFTopBarView = {
        let topBarView = Bundle.main.loadNibNamed("JFTopBarView", owner: nil, options: nil)?.last as! JFTopBarView
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
        contentScrollView.isPagingEnabled = true
        contentScrollView.alwaysBounceHorizontal = true
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.delegate = self
        contentScrollView.backgroundColor = COLOR_ALL_BG
        return contentScrollView
    }()
    
    /// 视频信息和播放列表
    lazy var videoTableView: UITableView = {
        let videoTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        videoTableView.delegate = self
        videoTableView.dataSource = self
        videoTableView.backgroundColor = COLOR_ALL_BG
        videoTableView.separatorStyle = .none
        videoTableView.register(UINib(nibName: "JFDetailVideoCell", bundle: nil), forCellReuseIdentifier: self.videoCellIdentifier)
        return videoTableView
    }()
    
    /// 评论
    lazy var commentTableView: UITableView = {
        let commentTableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.showsVerticalScrollIndicator = false
        commentTableView.backgroundColor = COLOR_ALL_BG
        commentTableView.separatorStyle = .none
        commentTableView.register(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentCellIdentifier)
        commentTableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        return commentTableView
    }()
    
    /// 底部工具条
    lazy var bottomBarView: JFDetailBottomBarView = {
        let bottomBarView = Bundle.main.loadNibNamed("JFDetailBottomBarView", owner: nil, options: nil)?.last as! JFDetailBottomBarView
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
        let view = Bundle.main.loadNibNamed("JFSelectNodeView", owner: nil, options: nil)?.last as! JFSelectNodeView
        view.delegate = self
        return view
    }()
    
    /// 分享视图
    fileprivate lazy var shareView: JFShareView = {
        let shareView = JFShareView()
        shareView.delegate = self
        return shareView
    }()
    
}

// MARK: - BMPlayerDelegate
extension JFPlayerViewController: BMPlayerDelegate {
    
    func playerStatusChanged(_ status: BMPlayerState) {
        
        if status == .playedToTheEnd {
            // 自动播放下一节
            if currentIndex < videos.count - 1 {
                currentIndex += 1
                videoTableView.selectRow(at: IndexPath(row: currentIndex, section: 0), animated: false, scrollPosition: .none)
                tableView(videoTableView, didSelectRowAt: IndexPath(row: currentIndex, section: 0))
            }
        }
        
    }
}

// MARK: - GADInterstitialDelegate 插页广告相关方法
extension JFPlayerViewController: GADInterstitialDelegate {
    
    /**
     当插页广告dismiss后初始化插页广告对象
     */
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
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
        interstitial.load(GADRequest())
        return interstitial
    }
    
}

// MARK: - 屏幕旋转
extension JFPlayerViewController  {
    
    /**
     监听屏幕方向发生改变 - 屏幕旋转时自动切换
     */
    @objc fileprivate func onOrientationChanged(_ notification: Notification) {
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        // 全屏
        if orientation == .landscapeRight || orientation == .landscapeLeft {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
            self.player.snp.updateConstraints({ (make) in
                make.top.equalTo(view.snp.top).offset(0)
            })
        }
        
        // 竖屏
        if orientation == .portrait || orientation == .portraitUpsideDown {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
            self.player.snp.updateConstraints({ (make) in
                make.top.equalTo(view.snp.top).offset(64)
            })
        }
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if toInterfaceOrientation == UIInterfaceOrientation.portrait || toInterfaceOrientation == UIInterfaceOrientation.portraitUpsideDown {
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == videoTableView {
            return videos.count
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == videoTableView {
            return 10
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == videoTableView {
            let sectionView = UIView()
            sectionView.backgroundColor = UIColor.colorWithHexString("f7f7f7")
            return sectionView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == videoTableView {
            return 44
        } else {
            let comment = comments[indexPath.row]
            if Int(comment.rowHeight) == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! JFCommentCell
                let height = cell.getRowHeight(comment)
                comment.rowHeight = height
            }
            return comment.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == videoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: videoCellIdentifier) as! JFDetailVideoCell
            cell.delegate = self
            cell.model = videos[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier) as! JFCommentCell
            cell.comment = comments[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 当前播放的下标
        currentIndex = indexPath.row
        
        if tableView == videoTableView {
            
            // 选中
            for video in videos {
                video.videoListSelected = false
            }
            videos[indexPath.row].videoListSelected = true
            
            player.prepareToDealloc()
            
            if JFAccountModel.isLogin() || indexPath.row == 0 {
                self.playVideo(videos[indexPath.row])
            } else {
                let alertController = UIAlertController(title: "您未登录", message: "为了营造一个良好的学习社区,您需要登录后才能继续观看更多视频哦！", preferredStyle: UIAlertControllerStyle.alert)
                let confirm = UIAlertAction(title: "确定登录", style: UIAlertActionStyle.destructive, handler: { (action) in
                    isLogin(self)
                })
                let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in })
                alertController.addAction(confirm)
                alertController.addAction(cancel)
                present(alertController, animated: true, completion: nil)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            
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
    
    func commentCell(_ cell: JFCommentCell, didTappedAtUser nickname: String, sequence: Int) {
        guard let atUser = cell.comment?.extendsAuthor else {
            return
        }
        
        if atUser.nickname == nickname {
            let otherUser = JFOtherUserViewController()
            otherUser.userId = atUser.id
            navigationController?.pushViewController(otherUser, animated: true)
        }
    }
    
    func commentCell(_ cell: JFCommentCell, didTappedAvatarButton button: UIButton) {
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    func didTappedChangeLineButton(_ button: UIButton) {
        selectNodeView.show()
    }
    
    /**
     下载视频
     */
    func didTappedDownloadButton(_ button: UIButton) {
        
        if UserDefaults.standard.bool(forKey: KEY_ALLOW_CELLULAR_DOWNLOAD) || JFNetworkTools.shareNetworkTool.getCurrentNetworkState() <= 1 {
            let videoDownloadVc = JFVideoDownloadViewController()
            videoDownloadVc.videos = videos
            videoDownloadVc.videoInfo = videoInfo
            present(videoDownloadVc, animated: true, completion: nil)
        } else {
            let alertC = UIAlertController(title: "温馨提示", message: "当前无可用WiFi，继续下载会扣流量哦", preferredStyle: UIAlertControllerStyle.alert)
            let continuePlay = UIAlertAction(title: "继续下载", style: UIAlertActionStyle.destructive, handler: { (acion) in
                UserDefaults.standard.set(true, forKey: KEY_ALLOW_CELLULAR_DOWNLOAD)
                let videoDownloadVc = JFVideoDownloadViewController()
                videoDownloadVc.videos = self.videos
                videoDownloadVc.videoInfo = self.videoInfo
                self.present(videoDownloadVc, animated: true, completion: nil)
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (acion) in })
            alertC.addAction(continuePlay)
            alertC.addAction(cancel)
            present(alertC, animated: true, completion: nil)
        }
        
    }
    
    /**
     分享
     */
    func didTappedShareButton(_ button: UIButton) {
        
        if JFShareItemModel.loadShareItems().count == 0 {
            JFProgressHUD.showInfoWithStatus("没有可分享内容")
            return
        }
        
        // 弹出分享视图
        shareView.showShareView()
    }
    
    /**
     加入收藏
     */
    func didTappedJoinCollectionButton(_ button: UIButton) {
        if isLogin(self) {
            JFNetworkTools.shareNetworkTool.addOrCancelCollection(videoInfo!.id) { (success, result, error) in
                guard let result = result, result["status"] == "success" else {
                    return
                }
                JFProgressHUD.showInfoWithStatus("操作成功")
                if result["result"]["type"].stringValue == "add" {
                    // 赞
                    self.bottomBarView.joinCollectionButton.setTitle("取消收藏", for: UIControlState())
                } else {
                    // 取消赞
                    self.bottomBarView.joinCollectionButton.setTitle("收藏课程", for: UIControlState())
                }
            }
        }
        
    }
}

// MARK: - JFShareViewDelegate
extension JFPlayerViewController: JFShareViewDelegate {
    
    func share(type: JFShareType) {
        
        let platformType: SSDKPlatformType!
        switch type {
        case .qqFriend:
            platformType = SSDKPlatformType.subTypeQZone // 尼玛，这竟然是反的。。ShareSDK bug
        case .qqQzone:
            platformType = SSDKPlatformType.subTypeQQFriend // 尼玛，这竟然是反的。。
        case .weixinFriend:
            platformType = SSDKPlatformType.subTypeWechatSession
        case .friendCircle:
            platformType = SSDKPlatformType.subTypeWechatTimeline
        }
        
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "最棒的自学英语社区，海量免费英语视频，涵盖音标、单词、语法、口语、听力、阅读、作文等内容！你还等什么呢？马上一起学习吧！",
                                          images : UIImage(named: "share"),
                                          url : URL(string: "https://itunes.apple.com/cn/app/id\(APPLE_ID)"),
                                          title : videoInfo!.title!,
                                          type : SSDKContentType.auto)
        
        ShareSDK.share(platformType, parameters: shareParames) { (state, _, entity, error) in
            switch state {
            case SSDKResponseState.success:
                print("分享成功")
            case SSDKResponseState.fail:
                print("授权失败,错误描述:\(error)")
            case SSDKResponseState.cancel:
                print("操作取消")
            default:
                break
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
    func didTappedSendButton(_ text: String) {
        
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
    func didTappedAppButton(_ button: UIButton) {
        nodeIndex = 0
    }
    
    /**
     选择了web节点
     */
    func didTappedWebButton(_ button: UIButton) {
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
    func M3U8VideoDownloadFailWithVideoId(_ videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(0, videoInfoId: videoInfoId, index: index, state: VideoState.noDownload)
    }
    
    /**
     解析视频视频 - 不是有效的m3u8地址
     
     - parameter videoVid:    视频的vid
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadParseFailWithVideoId(_ videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(0, videoInfoId: videoInfoId, index: index, state: VideoState.noDownload)
    }
    
    /**
     下载视频完成
     
     - parameter videoVid:    视频的vid
     - parameter path:        视频下载完成后的本地路径
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadFinishWithVideoId(_ videoVid: String, localPath path: String, videoInfoId: Int, index: Int) {
        videoStateChange(1.0, videoInfoId: videoInfoId, index: index, state: VideoState.alreadyDownload)
    }
    
    /**
     正在下载 更新进度
     
     - parameter progress:    下载进度 0.0 - 1.0
     - parameter videoVid:    视频的vid
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     */
    func M3U8VideoDownloadProgress(_ progress: CGFloat, withVideoVid videoVid: String, videoInfoId: Int, index: Int) {
        videoStateChange(progress, videoInfoId: videoInfoId, index: index, state: VideoState.downloading)
    }
    
    /**
     下载状态发生改变
     
     - parameter progress:    下载进度 0.0 - 1.0
     - parameter videoInfoId: 视频所属的视频信息id
     - parameter index:       视频模型数组下标
     - parameter state:       视频当前的状态
     */
    func videoStateChange(_ progress: CGFloat, videoInfoId: Int, index: Int, state: VideoState) {
        if videoInfoId == videoInfo?.id ?? 0 && index <= videos.count - 1 {
            let video = videos[index]
            video.state = state
            video.progress = progress
            
            // 防止cell还没有缓存
            if let cell = videoTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? JFDetailVideoCell  {
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
    func didTappedDownloadButton(_ cell: JFDetailVideoCell, button: UIButton) {
        
        if !JFAccountModel.isLogin() {
            let alertC = UIAlertController(title: "只有注册用户才能操作哦", message: "登录后可以无限制观看和下载视频教程哦", preferredStyle: UIAlertControllerStyle.alert)
            let confirm = UIAlertAction(title: "登录", style: UIAlertActionStyle.destructive, handler: { (action) in
                isLogin(self)
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in })
            alertC.addAction(confirm)
            alertC.addAction(cancel)
            present(alertC, animated: true, completion: { })
            return
        }
        
        let indexPath = videoTableView.indexPath(for: cell)!
        let video = videos[indexPath.row]
        
        switch video.state {
        case VideoState.noDownload:
            
            video.state = VideoState.downloading
            JFDownloadManager.shareManager.startDownloadVideo(videoInfo?.id ?? 0, index: indexPath.row, videoUrl: video.videoUrl ?? "")
            
        case VideoState.alreadyDownload:
            
            if video.videoListSelected {
                JFProgressHUD.showInfoWithStatus("您正在播放这个视频哦")
                return
            }
            
            let alertC = UIAlertController(title: "确认要删除这节视频吗", message: "删除缓存后，可以节省手机磁盘空间，但重新缓存又得WiFi哦", preferredStyle: UIAlertControllerStyle.alert)
            let confirm = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.destructive, handler: { (action) in
                video.state = VideoState.noDownload
                let videoVid = JFVideo.getVideoId(video.videoUrl!)
                
                // 从数据库移除
                JFDALManager.shareManager.removeVideo(videoVid, finished: { (success) in
                    if success {
                        // 从本地文件移除
                        let path = "\(DOWNLOAD_PATH)\(videoVid)"
                        let fileManager = FileManager.default
                        if fileManager.fileExists(atPath: path) {
                            do {
                                try fileManager.removeItem(atPath: path)
                                print("删除成功")
                                self.videoStateChange(0, videoInfoId: self.videoInfo?.id ?? 0, index: indexPath.row, state: VideoState.noDownload)
                            } catch {
                                print("删除失败")
                            }
                        }
                    }
                })
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in })
            alertC.addAction(confirm)
            alertC.addAction(cancel)
            present(alertC, animated: true, completion: { })
            
        case VideoState.downloading:
            
            video.state = VideoState.noDownload
            videoStateChange(0, videoInfoId: videoInfo?.id ?? 0, index: indexPath.row, state: VideoState.noDownload)
            JFDownloadManager.shareManager.cancelDownloadVideo(video.videoUrl!)
            
        }
        
    }
}
