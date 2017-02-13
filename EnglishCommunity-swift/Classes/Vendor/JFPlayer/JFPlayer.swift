//
//  JFPlayer.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/3.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//


import UIKit
import SnapKit
import IJKMediaFramework

/// 播放器状态
enum JFPlayerState {
    case unknown         // 未知
    case playable        // 可以播放
    case playthroughOK   // 从头到尾播放OK
    case stalled         // 熄火
    case playbackEnded   // 播放正常结束
    case playbackError   // 播放错误
    case userExited      // 用户退出
    case stopped         // 停止
    case paused          // 暂停
    case playing         // 正在播放
    case interrupted     // 中断
    case seekingForward  // 快退
    case seekingBackward // 快进
    case notSetURL       // 未设置URL
    case buffering       // 缓冲中
    case bufferFinished  // 缓冲完毕
    case fullScreen      // 全屏
    case compactScreen   // 竖屏
}

/**
 滑动方向
 
 - Horizontal: 水平
 - Vertical:   垂直
 */
enum JFPanDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

/**
 播放类型
 
 - URL:          URL播放
 - JFPlayerItem: JFPlayerItem模型
 */
enum JFPlayerItemType {
    case url
    case jfPlayerItem
}

protocol JFPlayerDelegate: NSObjectProtocol {
    
    func player(_ player: JFPlayer, playerStateChanged state: JFPlayerState)
}

class JFPlayer: UIView {
    
    weak var delegate: JFPlayerDelegate?
    
    /// 更新时间和缓冲进度的定时器
    var timer: Timer!
    
    /// 当前播放的视频的URL
    var currentPlayURL: URL!
    
    /// 播放器
    fileprivate var player: IJKMediaPlayback!
    
    /// 播放器控制视图
    fileprivate var controlView: JFPlayerControlView!
    
    /// 是否是全屏状态
    fileprivate var isFullScreen: Bool {
        get {
            // 如果状态栏方向是横向则是全屏
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
    
    /// 滑动方向
    fileprivate var panDirection = JFPanDirection.horizontal
    
    /// 音量滑竿 - 真机才有
    fileprivate var volumeViewSlider: UISlider!
    
    fileprivate let JFPlayerAnimationTimeInterval: Double = 4.0
    fileprivate let JFPlayerControlBarAutoFadeOutTimeInterval: Double = 0.5
    
    /// 用来保存时间状态
    fileprivate var sumTime: TimeInterval = 0
    
    fileprivate var isSliderSliding = false // 是否正在滑动滑条
    fileprivate var isVolume        = false // 是否是调整音量
    fileprivate var isMaskShowing   = false // 控制器UI是否显示
    fileprivate var isMirrored      = false // 是否开启镜像
    
    /// 当前播放速度的下标
    fileprivate var currentPlayIndex = 1
    /// 支持的播放速度
    fileprivate var speeds: [Float] = [0.5, 1.0, 1.3, 1.5, 1.7, 2.0]
    
    /**
     准备UI数据
     */
    fileprivate func prepareUI() {
        self.backgroundColor = UIColor.black
        
        configureVolume()
        controlView =  JFPlayerControlView()
        addSubview(controlView.getView)
        controlView.updateUI(isFullScreen)
        controlView.delegate = self
        
        controlView.getView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        // 敲击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        // 滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDirection(_:)))
        addGestureRecognizer(panGesture)
        
        controlView.playerPlayButton?.addTarget(self, action: #selector(self.playButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        controlView.playerFullScreenButton?.addTarget(self, action: #selector(self.fullScreenButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        controlView.playerBackButton?.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        // 时间滑条
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: UIControlEvents.touchDown)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [UIControlEvents.touchUpInside,UIControlEvents.touchCancel, UIControlEvents.touchUpOutside])
        
        controlView.playerSlowButton?.addTarget(self, action: #selector(slowButtonPressed(_:)), for: .touchUpInside)
        controlView.playerMirrorButton?.addTarget(self, action: #selector(mirrorButtonPressed(_:)), for: .touchUpInside)
        
        // 屏幕旋转监听
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        // 更新播放时间的定时器
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    /**
     配置音量调节视图 - 真机才有效果
     */
    fileprivate func configureVolume() {
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                volumeViewSlider = slider
            }
        }
    }
    
    /**
     直接使用URL播放
     
     - parameter url:   视频URL
     - parameter title: 视频标题
     */
    func playWithURL(_ url: URL, title: String = "") {
        
        // 保存当前播放的URL
        currentPlayURL = url
        prepareUI()
        let options = IJKFFOptions()
        // 开启硬解码
        options.setPlayerOptionValue("1", forKey: "videotoolbox")
        player = IJKFFMoviePlayerController(contentURL: url, with: options)
        player.scalingMode = IJKMPMovieScalingMode.aspectFill
        controlView.insertSubview(player.view, at: 0)
        player.view.snp.makeConstraints { (make) in
            make.edges.equalTo(controlView)
        }
        
        controlView.playerTitleLabel?.text = title
        
        // 没有自动播放就播放
        player.prepareToPlay()
        controlView.playerPlayButton?.isSelected = true
        installMovieNotificationObservers()
        controlView.showLoader()
        
        // 自动播放
        if JFPlayerConf.shouldAutoPlay {
            player.shouldAutoplay = true
        }
        
    }
    
    /**
     播放可切换清晰度的视频
     
     - parameter items: 清晰度列表
     - parameter title: 视频标题
     - parameter definitionIndex: 起始清晰度
     */
    func playWithPlayerItem(_ item: JFPlayerItem, definitionIndex: Int = 0) {
        
        // 保存当前播放的URL
        currentPlayURL = item.resource[definitionIndex].playURL as URL
        prepareUI()
        
        let options = IJKFFOptions()
        // 开启硬解码
        options.setPlayerOptionValue("1", forKey: "videotoolbox")
        player = IJKFFMoviePlayerController(contentURL: item.resource[definitionIndex].playURL as URL, with: options)
        player.scalingMode = IJKMPMovieScalingMode.aspectFill
        controlView.insertSubview(player.view, at: 0)
        player.view.snp.makeConstraints { (make) in
            make.edges.equalTo(controlView)
        }
        
        controlView.playerTitleLabel?.text = item.title
        controlView.showCoverWithLink(item.cover)
        
        // 没有自动播放就播放
        player.prepareToPlay()
        controlView.playerPlayButton?.isSelected = true
        installMovieNotificationObservers()
        controlView.showLoader()
        
        // 自动播放
        if JFPlayerConf.shouldAutoPlay {
            player.shouldAutoplay = true
        }
    }
    
    /**
     使用自动播放
     */
    func autoPlay() {
        if let player = player {
            player.shouldAutoplay = true
            play()
        }
    }
    
    /**
     手动播放
     */
    func play() {
        if let player = player {
            if !player.isPlaying() {
                player.play()
                controlView.playerPlayButton?.isSelected = true
            }
        }
    }
    
    /**
     手动暂停
     */
    func pause() {
        if let player = player {
            if player.isPlaying() {
                player.pause()
                controlView.playerPlayButton?.isSelected = false
                cancelAutoFadeOutControlBar()
            }
        }
    }
    
    /**
     准备销毁，移除各种资源
     */
    func prepareToDealloc() {
        if let player = player {
            player.shutdown()
            controlView.removeFromSuperview()
            timer.invalidate()
            removeMovieNotificationObservers()
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        }
        
    }
    
}

// MARK: - 内部事件
extension JFPlayer {
    
    /**
     创建定时器
     */
    fileprivate func startTimer() {
        timer.fireDate = Date.distantPast
    }
    
    /**
     销毁定时器
     */
    fileprivate func pauseTimer() {
        timer.fireDate = Date.distantFuture
    }
    
    /**
     敲击手势 隐藏/显示
     */
    @objc fileprivate func tapGestureTapped(_ sender: UIGestureRecognizer) {
        if isMaskShowing {
            hideControlViewAnimated()
            autoFadeOutControlBar()
        } else {
            showControlViewAnimated()
        }
    }
    
    /**
     开始自动隐藏UI倒计时
     */
    @objc fileprivate func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControlViewAnimated), object: nil)
        perform(#selector(hideControlViewAnimated), with: nil, afterDelay: JFPlayerAnimationTimeInterval)
    }
    
    /**
     取消UI自动隐藏操作
     */
    @objc fileprivate func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    /**
     显示控制UI视图
     */
    @objc fileprivate func showControlViewAnimated() {
        UIView.animate(withDuration: JFPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showPlayerUIComponents()
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        }, completion: { (_) in
            self.autoFadeOutControlBar()
            self.isMaskShowing = true
        }) 
    }
    
    /**
     隐藏控制UI视图
     */
    @objc fileprivate func hideControlViewAnimated() {
        UIView.animate(withDuration: JFPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hidePlayerUIComponents()
            if self.isFullScreen {
                UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
            }
        }, completion: { (_) in
            self.isMaskShowing = false
        }) 
    }
    
    /**
     滑动手势 调节播放时间/音量
     */
    @objc fileprivate func panDirection(_ pan: UIPanGestureRecognizer) {
        
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizerState.began:
            
            // 使用绝对值来判断移动的方向
            let x = fabs(velocityPoint.x)
            let y = fabs(velocityPoint.y)
            
            if x > y {
                panDirection = JFPanDirection.horizontal
                
                // 记录当前播放的时间
                sumTime = player.currentPlaybackTime
                
            } else {
                panDirection = JFPanDirection.vertical
                
                if locationPoint.x > self.bounds.size.width / 2 {
                    isVolume = true
                } else {
                    isVolume = false
                }
            }
            
        case UIGestureRecognizerState.changed:
            
            cancelAutoFadeOutControlBar()
            switch self.panDirection {
            case JFPanDirection.horizontal:
                horizontalMoved(velocityPoint.x)
            case JFPanDirection.vertical:
                verticalMoved(velocityPoint.y)
            }
            
        case UIGestureRecognizerState.ended:
            
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (panDirection) {
            case JFPanDirection.horizontal:
                
                controlView.hideSeekToView()
                isSliderSliding = false
                
                seekToTime(Int(sumTime))
                
                // 把sumTime滞空，不然会越加越多
                sumTime = 0.0
                
            case JFPanDirection.vertical:
                isVolume = false
            }
        default:
            break
        }
    }
    
    /**
     垂直滑动调节音量 - 需要真机才有效果
     */
    fileprivate func verticalMoved(_ value: CGFloat) {
        // 滑动左边则调节亮度 滑动右边则调节声音
        isVolume ? (volumeViewSlider.value -= Float(value / 10000)) : (UIScreen.main.brightness -= value / 10000)
    }
    
    /**
     水平滑动调节播放时间
     */
    fileprivate func horizontalMoved(_ value: CGFloat) {
        
        isSliderSliding = true
        
        // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
        sumTime = sumTime + TimeInterval(value) / 100.0 * (player.duration / 400)
        
        // 防止出现NAN
        if player.duration == 0 {
            return
        }
        
        if (sumTime > player.duration) {
            sumTime = player.duration
        }
        
        if (sumTime < 0) {
            sumTime = 0
        }
        
        controlView.playerTimeSlider?.value = Float(sumTime / player.duration)
        controlView.playerCurrentTimeLabel?.text = formatSecondsToString(sumTime)
        controlView.showSeekToView(sumTime, isAdd: value > 0)
    }
    
    /**
     进度条开始滑动 手按下
     */
    @objc fileprivate func progressSliderTouchBegan(_ sender: UISlider)  {
        isSliderSliding = true
    }
    
    /**
     进度条值改变 滑动中。。。
     */
    @objc fileprivate func progressSliderValueChanged(_ sender: UISlider)  {
        cancelAutoFadeOutControlBar()
        controlView.playerCurrentTimeLabel?.text = formatSecondsToString(player.duration * Double(sender.value))
    }
    
    /**
     进度条滑动结束 手松开
     */
    @objc fileprivate func progressSliderTouchEnded(_ sender: UISlider)  {
        
        isSliderSliding = false
        autoFadeOutControlBar()
        seekToTime(Int(player.duration * Double(sender.value)))
        play()
    }
    
    /**
     点击了返回箭头
     */
    @objc fileprivate func backButtonPressed(_ button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        }
    }
    
    /**
     点击播放/暂停按钮
     */
    @objc fileprivate func playButtonPressed(_ button: UIButton) {
        if button.isSelected {
            pause()
        } else {
            play()
        }
    }
    
    /**
     点击了慢放
     */
    @objc fileprivate func slowButtonPressed(_ button: UIButton) {
        
        // 调到下一个速度
        currentPlayIndex += 1
        currentPlayIndex %= speeds.count
        
        // 自动隐藏UI并设置播放速度和按钮文字
        autoFadeOutControlBar()
        player.playbackRate = speeds[currentPlayIndex]
        controlView.playerSlowButton?.setTitle("\(speeds[currentPlayIndex])X", for: UIControlState())
    }
    
    /**
     点击了镜像
     */
    @objc fileprivate func mirrorButtonPressed(_ button: UIButton) {
        autoFadeOutControlBar()
        if isMirrored {
            transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            isMirrored = false
            controlView.playerMirrorButton?.setTitle("镜像", for: UIControlState())
        } else {
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            isMirrored = true
            controlView.playerMirrorButton?.setTitle("正常", for: UIControlState())
        }
    }
    
    /**
     监听屏幕方向发生改变 - 屏幕旋转时自动切换
     */
    @objc fileprivate func onOrientationChanged() {
        controlView.updateUI(isFullScreen)
        delegate?.player(self, playerStateChanged: isFullScreen ? JFPlayerState.fullScreen : JFPlayerState.compactScreen)
    }
    
    /**
     切换全屏按钮点击事件 - 手动点击旋转
     */
    @objc fileprivate func fullScreenButtonPressed(_ button: UIButton?) {
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: false)
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
            UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)
        }
    }
    
    /**
     将秒转成时间格式
     
     - parameter secounds: 秒数
     
     - returns: 时间格式字符串
     */
    fileprivate func formatSecondsToString(_ secounds: TimeInterval) -> String {
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    /**
     更新播放时间label
     */
    @objc fileprivate func updatePlayTime() {
        
        JFPlayerManager.shared.log("updatePlayTime - \(player.currentPlaybackTime) - \(player.duration)")
        
        if isSliderSliding {
            return
        }
        
        controlView.playerCurrentTimeLabel?.text = "\(formatSecondsToString(player.currentPlaybackTime))"
        controlView.playerTotalTimeLabel?.text = "\(formatSecondsToString(player.duration))"
        controlView.playerTimeSlider?.value = Float(player.currentPlaybackTime) / Float(player.duration)
        
        // 更新缓冲进度
        if player.duration > 0 && Float(player.playableDuration) / Float(player.duration) > 0.8 {
            controlView.playerProgressView?.setProgress(1.0, animated: true)
        } else if player.duration > 0 {
            controlView.playerProgressView?.setProgress(Float(player.playableDuration) / Float(player.duration), animated: true)
        }
        
    }
    
    /**
     调整播放时间
     
     - parameter second: 需要调整到的秒
     */
    fileprivate func seekToTime(_ second: Int) {
        player.currentPlaybackTime = TimeInterval(second)
    }
    
}

// MARK: - BMPlayerControlViewDelegate
extension JFPlayer: JFPlayerControlViewDelegate {
    
    /**
     选择清晰度/节点
     */
    func controlViewDidChooseDefition(_ index: Int) {
        log("controlViewDidChooseDefition")
    }
    
    /**
     重播
     */
    func controlViewDidPressOnReply() {
        log("controlViewDidPressOnReply")
        
        prepareToDealloc()
        playWithURL(currentPlayURL)
    }
}

// MARK: - IJK内置通知
extension JFPlayer {
    
    /**
     注册通知
     */
    fileprivate func installMovieNotificationObservers() {
        
        // 播放器加载状态改变
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        
        // 播放器完成播放
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        
        // 播放器状态改变
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    /**
     移除通知
     */
    fileprivate func removeMovieNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    /**
     加载状态发生改变监听
     */
    @objc fileprivate func loadStateDidChange(_ notification: Notification) {
        
        let loadState = player.loadState
        
        switch loadState {
        case IJKMPMovieLoadState():
            JFPlayerManager.shared.log("加载状态 - 未知")
            
            // 显示加载UI
            controlView.showLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .unknown)
            
        case IJKMPMovieLoadState.playable:
            JFPlayerManager.shared.log("加载状态 - 可播放")
            
            // 隐藏加载UI
            controlView.hideLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .playable)
            
        case IJKMPMovieLoadState.playthroughOK:
            JFPlayerManager.shared.log("加载状态 - 播放")
            
            // 隐藏加载UI
            controlView.hideLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .playthroughOK)
            
        case IJKMPMovieLoadState.stalled:
            JFPlayerManager.shared.log("加载状态 - 熄火")
            
            // 显示加载UI
            controlView.showLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .stalled)
            
        default:
            log("加载状态改变")
            return
        }
        
    }
    
    /**
     视频播放完成监听
     */
    @objc fileprivate func moviePlayBackDidFinish(_ notification: Notification) {
        
        let reason = IJKMPMovieFinishReason(rawValue: Int(notification.userInfo!["IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey"]! as! NSNumber))!
        switch reason {
        case IJKMPMovieFinishReason.playbackEnded:
            JFPlayerManager.shared.log("播放结束")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playbackEnded)
            
        case IJKMPMovieFinishReason.playbackError:
            JFPlayerManager.shared.log("播放错误")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playbackError)
            
        case IJKMPMovieFinishReason.userExited:
            JFPlayerManager.shared.log("用户退出")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .userExited)
            
        }
        
        // 显示播放结束图标
        controlView.showPlayToTheEndView()
        
        // 隐藏加载UI
        controlView.hideLoader()
    }
    
    @objc fileprivate func mediaIsPreparedToPlayDidChange(_ notification: Notification) {
        JFPlayerManager.shared.log("mediaIsPreparedToPlayDidChange")
    }
    
    /**
     视频播放状态改变监听
     */
    @objc fileprivate func moviePlayBackStateDidChange(_ notification: Notification) {
        
        switch player.playbackState {
        case IJKMPMoviePlaybackState.stopped:
            JFPlayerManager.shared.log("已经停止")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.isSelected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .stopped)
            
        case IJKMPMoviePlaybackState.playing:
            JFPlayerManager.shared.log("正在播放")
            
            // 开启定时器并隐藏加载UI
            startTimer()
            controlView.hideLoader()
            
            // 开启自动渐变隐藏控制UI
            autoFadeOutControlBar()
            
            // 切换到播放图标
            controlView.playerPlayButton?.isSelected = true
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .playing)
            
        case IJKMPMoviePlaybackState.paused:
            JFPlayerManager.shared.log("已经暂停")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.isSelected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .paused)
            
        case IJKMPMoviePlaybackState.interrupted:
            JFPlayerManager.shared.log("已经中断")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.isSelected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .interrupted)
            
        case IJKMPMoviePlaybackState.seekingForward:
            JFPlayerManager.shared.log("已经快退")
            
            // 切换到暂停图标
            controlView.playerPlayButton?.isSelected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .seekingForward)
            
        case IJKMPMoviePlaybackState.seekingBackward:
            JFPlayerManager.shared.log("已经快退")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .seekingBackward)
            
        }
        
    }
}
