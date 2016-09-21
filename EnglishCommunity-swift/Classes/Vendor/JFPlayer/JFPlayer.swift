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
    case Unknown         // 未知
    case Playable        // 可以播放
    case PlaythroughOK   // 从头到尾播放OK
    case Stalled         // 熄火
    case PlaybackEnded   // 播放正常结束
    case PlaybackError   // 播放错误
    case UserExited      // 用户退出
    case Stopped         // 停止
    case Paused          // 暂停
    case Playing         // 正在播放
    case Interrupted     // 中断
    case SeekingForward  // 快退
    case SeekingBackward // 快进
    case NotSetURL       // 未设置URL
    case Buffering       // 缓冲中
    case BufferFinished  // 缓冲完毕
    case FullScreen      // 全屏
    case CompactScreen   // 竖屏
}

/**
 滑动方向
 
 - Horizontal: 水平
 - Vertical:   垂直
 */
enum JFPanDirection: Int {
    case Horizontal = 0
    case Vertical   = 1
}

/**
 播放类型
 
 - URL:          URL播放
 - JFPlayerItem: JFPlayerItem模型
 */
enum JFPlayerItemType {
    case URL
    case JFPlayerItem
}

protocol JFPlayerDelegate: NSObjectProtocol {
    
    func player(player: JFPlayer, playerStateChanged state: JFPlayerState)
}

class JFPlayer: UIView {
    
    weak var delegate: JFPlayerDelegate?
    
    /// 更新时间和缓冲进度的定时器
    var timer: NSTimer!
    
    /// 当前播放的视频的URL
    var currentPlayURL: NSURL!
    
    /// 播放器
    private var player: IJKMediaPlayback!
    
    /// 播放器控制视图
    private var controlView: JFPlayerControlView!
    
    /// 是否是全屏状态
    private var isFullScreen: Bool {
        get {
            // 如果状态栏方向是横向则是全屏
            return UIApplication.sharedApplication().statusBarOrientation.isLandscape
        }
    }
    
    /// 滑动方向
    private var panDirection = JFPanDirection.Horizontal
    
    /// 音量滑竿 - 真机才有
    private var volumeViewSlider: UISlider!
    
    private let JFPlayerAnimationTimeInterval: Double = 4.0
    private let JFPlayerControlBarAutoFadeOutTimeInterval: Double = 0.5
    
    /// 用来保存时间状态
    private var sumTime: NSTimeInterval = 0
    
    private var isSliderSliding = false // 是否正在滑动滑条
    private var isVolume        = false // 是否是调整音量
    private var isMaskShowing   = false // 控制器UI是否显示
    private var isMirrored      = false // 是否开启镜像
    
    /// 当前播放速度的下标
    private var currentPlayIndex = 1
    /// 支持的播放速度
    private var speeds: [Float] = [0.5, 1.0, 1.3, 1.5, 1.7, 2.0]
    
    /**
     准备UI数据
     */
    private func prepareUI() {
        self.backgroundColor = UIColor.blackColor()
        
        configureVolume()
        controlView =  JFPlayerControlView()
        addSubview(controlView.getView)
        controlView.updateUI(isFullScreen)
        controlView.delegate = self
        
        controlView.getView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        // 敲击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        // 滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDirection(_:)))
        addGestureRecognizer(panGesture)
        
        controlView.playerPlayButton?.addTarget(self, action: #selector(self.playButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.playerFullScreenButton?.addTarget(self, action: #selector(self.fullScreenButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        controlView.playerBackButton?.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 时间滑条
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), forControlEvents: UIControlEvents.TouchDown)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        controlView.playerTimeSlider?.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), forControlEvents: [UIControlEvents.TouchUpInside,UIControlEvents.TouchCancel, UIControlEvents.TouchUpOutside])
        
        controlView.playerSlowButton?.addTarget(self, action: #selector(slowButtonPressed(_:)), forControlEvents: .TouchUpInside)
        controlView.playerMirrorButton?.addTarget(self, action: #selector(mirrorButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        // 屏幕旋转监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onOrientationChanged), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        // 更新播放时间的定时器
        timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(updatePlayTime), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    /**
     配置音量调节视图 - 真机才有效果
     */
    private func configureVolume() {
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
    func playWithURL(url: NSURL, title: String = "") {
        
        // 保存当前播放的URL
        currentPlayURL = url
        prepareUI()
        let options = IJKFFOptions()
        // 开启硬解码
        options.setPlayerOptionValue("1", forKey: "videotoolbox")
        player = IJKFFMoviePlayerController(contentURL: url, withOptions: options)
        player.scalingMode = IJKMPMovieScalingMode.AspectFill
        controlView.insertSubview(player.view, atIndex: 0)
        player.view.snp_makeConstraints { (make) in
            make.edges.equalTo(controlView)
        }
        
        controlView.playerTitleLabel?.text = title
        
        // 没有自动播放就播放
        player.prepareToPlay()
        controlView.playerPlayButton?.selected = true
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
    func playWithPlayerItem(item: JFPlayerItem, definitionIndex: Int = 0) {
        
        // 保存当前播放的URL
        currentPlayURL = item.resource[definitionIndex].playURL
        prepareUI()
        
        let options = IJKFFOptions()
        // 开启硬解码
        options.setPlayerOptionValue("1", forKey: "videotoolbox")
        player = IJKFFMoviePlayerController(contentURL: item.resource[definitionIndex].playURL, withOptions: options)
        player.scalingMode = IJKMPMovieScalingMode.AspectFill
        controlView.insertSubview(player.view, atIndex: 0)
        player.view.snp_makeConstraints { (make) in
            make.edges.equalTo(controlView)
        }
        
        controlView.playerTitleLabel?.text = item.title
        controlView.showCoverWithLink(item.cover)
        
        // 没有自动播放就播放
        player.prepareToPlay()
        controlView.playerPlayButton?.selected = true
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
                controlView.playerPlayButton?.selected = true
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
                controlView.playerPlayButton?.selected = false
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
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }
        
    }
    
}

// MARK: - 内部事件
extension JFPlayer {
    
    /**
     创建定时器
     */
    private func startTimer() {
        timer.fireDate = NSDate.distantPast()
    }
    
    /**
     销毁定时器
     */
    private func pauseTimer() {
        timer.fireDate = NSDate.distantFuture()
    }
    
    /**
     敲击手势 隐藏/显示
     */
    @objc private func tapGestureTapped(sender: UIGestureRecognizer) {
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
    @objc private func autoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(hideControlViewAnimated), object: nil)
        performSelector(#selector(hideControlViewAnimated), withObject: nil, afterDelay: JFPlayerAnimationTimeInterval)
    }
    
    /**
     取消UI自动隐藏操作
     */
    @objc private func cancelAutoFadeOutControlBar() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    }
    
    /**
     显示控制UI视图
     */
    @objc private func showControlViewAnimated() {
        UIView.animateWithDuration(JFPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.showPlayerUIComponents()
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        }) { (_) in
            self.autoFadeOutControlBar()
            self.isMaskShowing = true
        }
    }
    
    /**
     隐藏控制UI视图
     */
    @objc private func hideControlViewAnimated() {
        UIView.animateWithDuration(JFPlayerControlBarAutoFadeOutTimeInterval, animations: {
            self.controlView.hidePlayerUIComponents()
            if self.isFullScreen {
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            }
        }) { (_) in
            self.isMaskShowing = false
        }
    }
    
    /**
     滑动手势 调节播放时间/音量
     */
    @objc private func panDirection(pan: UIPanGestureRecognizer) {
        
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.locationInView(self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocityInView(self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizerState.Began:
            
            // 使用绝对值来判断移动的方向
            let x = fabs(velocityPoint.x)
            let y = fabs(velocityPoint.y)
            
            if x > y {
                panDirection = JFPanDirection.Horizontal
                
                // 记录当前播放的时间
                sumTime = player.currentPlaybackTime
                
            } else {
                panDirection = JFPanDirection.Vertical
                
                if locationPoint.x > self.bounds.size.width / 2 {
                    isVolume = true
                } else {
                    isVolume = false
                }
            }
            
        case UIGestureRecognizerState.Changed:
            
            cancelAutoFadeOutControlBar()
            switch self.panDirection {
            case JFPanDirection.Horizontal:
                horizontalMoved(velocityPoint.x)
            case JFPanDirection.Vertical:
                verticalMoved(velocityPoint.y)
            }
            
        case UIGestureRecognizerState.Ended:
            
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (panDirection) {
            case JFPanDirection.Horizontal:
                
                controlView.hideSeekToView()
                isSliderSliding = false
                
                seekToTime(Int(sumTime))
                
                // 把sumTime滞空，不然会越加越多
                sumTime = 0.0
                
            case JFPanDirection.Vertical:
                isVolume = false
            }
        default:
            break
        }
    }
    
    /**
     垂直滑动调节音量 - 需要真机才有效果
     */
    private func verticalMoved(value: CGFloat) {
        // 滑动左边则调节亮度 滑动右边则调节声音
        isVolume ? (volumeViewSlider.value -= Float(value / 10000)) : (UIScreen.mainScreen().brightness -= value / 10000)
    }
    
    /**
     水平滑动调节播放时间
     */
    private func horizontalMoved(value: CGFloat) {
        
        isSliderSliding = true
        
        // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
        sumTime = sumTime + NSTimeInterval(value) / 100.0 * (player.duration / 400)
        
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
    @objc private func progressSliderTouchBegan(sender: UISlider)  {
        isSliderSliding = true
    }
    
    /**
     进度条值改变 滑动中。。。
     */
    @objc private func progressSliderValueChanged(sender: UISlider)  {
        cancelAutoFadeOutControlBar()
        controlView.playerCurrentTimeLabel?.text = formatSecondsToString(player.duration * Double(sender.value))
    }
    
    /**
     进度条滑动结束 手松开
     */
    @objc private func progressSliderTouchEnded(sender: UISlider)  {
        
        isSliderSliding = false
        autoFadeOutControlBar()
        seekToTime(Int(player.duration * Double(sender.value)))
        play()
    }
    
    /**
     点击了返回箭头
     */
    @objc private func backButtonPressed(button: UIButton) {
        if isFullScreen {
            fullScreenButtonPressed(nil)
        }
    }
    
    /**
     点击播放/暂停按钮
     */
    @objc private func playButtonPressed(button: UIButton) {
        if button.selected {
            pause()
        } else {
            play()
        }
    }
    
    /**
     点击了慢放
     */
    @objc private func slowButtonPressed(button: UIButton) {
        
        // 调到下一个速度
        currentPlayIndex += 1
        currentPlayIndex %= speeds.count
        
        // 自动隐藏UI并设置播放速度和按钮文字
        autoFadeOutControlBar()
        player.playbackRate = speeds[currentPlayIndex]
        controlView.playerSlowButton?.setTitle("\(speeds[currentPlayIndex])X", forState: .Normal)
    }
    
    /**
     点击了镜像
     */
    @objc private func mirrorButtonPressed(button: UIButton) {
        autoFadeOutControlBar()
        if isMirrored {
            transform = CGAffineTransformMakeScale(1.0, 1.0)
            isMirrored = false
            controlView.playerMirrorButton?.setTitle("镜像", forState: .Normal)
        } else {
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            isMirrored = true
            controlView.playerMirrorButton?.setTitle("正常", forState: .Normal)
        }
    }
    
    /**
     监听屏幕方向发生改变 - 屏幕旋转时自动切换
     */
    @objc private func onOrientationChanged() {
        controlView.updateUI(isFullScreen)
        delegate?.player(self, playerStateChanged: isFullScreen ? JFPlayerState.FullScreen : JFPlayerState.CompactScreen)
    }
    
    /**
     切换全屏按钮点击事件 - 手动点击旋转
     */
    @objc private func fullScreenButtonPressed(button: UIButton?) {
        if isFullScreen {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.Portrait, animated: false)
        } else {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            UIApplication.sharedApplication().setStatusBarOrientation(UIInterfaceOrientation.LandscapeRight, animated: false)
        }
    }
    
    /**
     将秒转成时间格式
     
     - parameter secounds: 秒数
     
     - returns: 时间格式字符串
     */
    private func formatSecondsToString(secounds: NSTimeInterval) -> String {
        let Min = Int(secounds / 60)
        let Sec = Int(secounds % 60)
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    /**
     更新播放时间label
     */
    @objc private func updatePlayTime() {
        
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
    private func seekToTime(second: Int) {
        player.currentPlaybackTime = NSTimeInterval(second)
    }
    
}

// MARK: - BMPlayerControlViewDelegate
extension JFPlayer: JFPlayerControlViewDelegate {
    
    /**
     选择清晰度/节点
     */
    func controlViewDidChooseDefition(index: Int) {
        print("controlViewDidChooseDefition")
    }
    
    /**
     重播
     */
    func controlViewDidPressOnReply() {
        print("controlViewDidPressOnReply")
        
        prepareToDealloc()
        playWithURL(currentPlayURL)
    }
}

// MARK: - IJK内置通知
extension JFPlayer {
    
    /**
     注册通知
     */
    private func installMovieNotificationObservers() {
        
        // 播放器加载状态改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadStateDidChange(_:)), name: IJKMPMoviePlayerLoadStateDidChangeNotification, object: player)
        
        // 播放器完成播放
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: IJKMPMoviePlayerPlaybackDidFinishNotification, object: player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: player)
        
        // 播放器状态改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: IJKMPMoviePlayerPlaybackStateDidChangeNotification, object: player)
    }
    
    /**
     移除通知
     */
    private func removeMovieNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerLoadStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerPlaybackDidFinishNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: IJKMPMoviePlayerPlaybackStateDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    /**
     加载状态发生改变监听
     */
    @objc private func loadStateDidChange(notification: NSNotification) {
        
        let loadState = player.loadState
        
        switch loadState {
        case IJKMPMovieLoadState.Unknown:
            JFPlayerManager.shared.log("加载状态 - 未知")
            
            // 显示加载UI
            controlView.showLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .Unknown)
            
        case IJKMPMovieLoadState.Playable:
            JFPlayerManager.shared.log("加载状态 - 可播放")
            
            // 隐藏加载UI
            controlView.hideLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .Playable)
            
        case IJKMPMovieLoadState.PlaythroughOK:
            JFPlayerManager.shared.log("加载状态 - 播放")
            
            // 隐藏加载UI
            controlView.hideLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .PlaythroughOK)
            
        case IJKMPMovieLoadState.Stalled:
            JFPlayerManager.shared.log("加载状态 - 熄火")
            
            // 显示加载UI
            controlView.showLoader()
            
            // 回调加载状态
            delegate?.player(self, playerStateChanged: .Stalled)
            
        default:
            print("加载状态改变")
            return
        }
        
    }
    
    /**
     视频播放完成监听
     */
    @objc private func moviePlayBackDidFinish(notification: NSNotification) {
        
        let reason = IJKMPMovieFinishReason(rawValue: Int(notification.userInfo!["IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey"]! as! NSNumber))!
        switch reason {
        case IJKMPMovieFinishReason.PlaybackEnded:
            JFPlayerManager.shared.log("播放结束")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .PlaybackEnded)
            
        case IJKMPMovieFinishReason.PlaybackError:
            JFPlayerManager.shared.log("播放错误")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .PlaybackError)
            
        case IJKMPMovieFinishReason.UserExited:
            JFPlayerManager.shared.log("用户退出")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .UserExited)
            
        }
        
        // 显示播放结束图标
        controlView.showPlayToTheEndView()
        
        // 隐藏加载UI
        controlView.hideLoader()
    }
    
    @objc private func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        JFPlayerManager.shared.log("mediaIsPreparedToPlayDidChange")
    }
    
    /**
     视频播放状态改变监听
     */
    @objc private func moviePlayBackStateDidChange(notification: NSNotification) {
        
        switch player.playbackState {
        case IJKMPMoviePlaybackState.Stopped:
            JFPlayerManager.shared.log("已经停止")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.selected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .Stopped)
            
        case IJKMPMoviePlaybackState.Playing:
            JFPlayerManager.shared.log("正在播放")
            
            // 开启定时器并隐藏加载UI
            startTimer()
            controlView.hideLoader()
            
            // 开启自动渐变隐藏控制UI
            autoFadeOutControlBar()
            
            // 切换到播放图标
            controlView.playerPlayButton?.selected = true
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .Playing)
            
        case IJKMPMoviePlaybackState.Paused:
            JFPlayerManager.shared.log("已经暂停")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.selected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .Paused)
            
        case IJKMPMoviePlaybackState.Interrupted:
            JFPlayerManager.shared.log("已经中断")
            
            // 暂停定时器
            pauseTimer()
            
            // 切换到暂停图标
            controlView.playerPlayButton?.selected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .Interrupted)
            
        case IJKMPMoviePlaybackState.SeekingForward:
            JFPlayerManager.shared.log("已经快退")
            
            // 切换到暂停图标
            controlView.playerPlayButton?.selected = false
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .SeekingForward)
            
        case IJKMPMoviePlaybackState.SeekingBackward:
            JFPlayerManager.shared.log("已经快退")
            
            // 回调播放器状态
            delegate?.player(self, playerStateChanged: .SeekingBackward)
            
        }
        
    }
}
