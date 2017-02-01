//
//  JFPlayerControlView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/2.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//


import UIKit
import NVActivityIndicatorView

/// 播放器控制视图的委托方法
public protocol JFPlayerControlViewDelegate: class {
    /**
     当用户选择改变定义的选项后调用
     call this mehod when user choose to change definetion
     
     - parameter index: definition item index
     */
    func controlViewDidChooseDefition(_ index: Int)
    
    /**
     当用户按了重播调用
     call this method when user press on replay
     */
    func controlViewDidPressOnReply()
}

class JFPlayerControlView: UIView {
    
    weak var delegate: JFPlayerControlViewDelegate?
    
    /// 播放器标题
    var playerTitleLabel        : UILabel?  { get { return  titleLabel } }
    
    /// 当前播放时间label
    var playerCurrentTimeLabel  : UILabel?  { get { return  currentTimeLabel } }
    
    /// 总共时长label
    var playerTotalTimeLabel    : UILabel?  { get { return  totalTimeLabel } }
    
    /// 播放/暂停按钮
    var playerPlayButton        : UIButton? { get { return  playButton } }
    
    /// 全屏按钮
    var playerFullScreenButton  : UIButton? { get { return  fullScreenButton } }
    
    /// 返回按钮
    var playerBackButton        : UIButton? { get { return  backButton } }
    
    /// 播放时间滑条
    var playerTimeSlider        : UISlider? { get { return  timeSlider } }
    
    /// 播放进度条
    var playerProgressView      : UIProgressView? { get { return  progressView } }
    
    /// 慢放
    var playerSlowButton        : UIButton? { get { return  slowButton } }
    
    /// 镜像
    var playerMirrorButton      : UIButton? { get { return  mirrorButton } }
    
    /// 获取播放器控制UI
    var getView: UIView { return self }
    
    /// 主体
    var mainMaskView    = UIView()
    var topMaskView     = UIView()
    var bottomMaskView  = UIView()
    var maskImageView   = UIImageView()
    
    /// 顶部
    var backButton  = UIButton(type: UIButtonType.custom)
    var titleLabel  = UILabel()
    var chooseDefitionView = UIView()
    
    /// 底部
    fileprivate var currentTimeLabel = UILabel()
    fileprivate var totalTimeLabel   = UILabel()
    
    fileprivate var timeSlider       = JFTimeSlider()
    fileprivate var progressView     = UIProgressView()
    
    fileprivate var playButton       = UIButton(type: UIButtonType.custom)
    fileprivate var fullScreenButton = UIButton(type: UIButtonType.custom)
    fileprivate var slowButton       = UIButton(type: UIButtonType.custom)
    fileprivate var mirrorButton     = UIButton(type: UIButtonType.custom)
    
    /// 中间部分
    var loadingIndector  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    
    var seekToView       = UIView()
    var seekToViewImage  = UIImageView()
    var seekToLabel      = UILabel()
    
    var centerButton     = UIButton(type: UIButtonType.custom)
    
    var videoItems: [JFPlayerItemDefinitionItem] = []
    
    var selectedIndex = 0
    
    fileprivate var isSelectecDefitionViewOpened = false
    
    var isFullScreen = false
    
    var maskViewColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:0.7)
    
    // MARK: - funcitons
    /**
     显示播放器UI组件
     */
    func showPlayerUIComponents() {
        topMaskView.alpha    = 1.0
        bottomMaskView.alpha = 1.0
        
        if isFullScreen {
            chooseDefitionView.alpha = 1.0
        }
    }
    
    /**
     隐藏播放器UI组件
     */
    func hidePlayerUIComponents() {
        centerButton.isHidden = true
        topMaskView.alpha    = 0.0
        bottomMaskView.alpha = 0.0
        
        chooseDefitionView.snp.updateConstraints { (make) in
            make.height.equalTo(35)
        }
        chooseDefitionView.alpha = 0.0
    }
    
    /**
     屏幕方向发生变化后更新UI
     
     - parameter isForFullScreen: 是否是充满全屏的
     */
    func updateUI(_ isForFullScreen: Bool) {
        isFullScreen = isForFullScreen
        
        if isForFullScreen {
            if JFPlayerConf.slowAndMirror {
                self.slowButton.isHidden = false
                self.mirrorButton.isHidden = false
                
                fullScreenButton.snp.remakeConstraints { (make) in
                    make.width.equalTo(50)
                    make.height.equalTo(50)
                    make.centerY.equalTo(currentTimeLabel)
                    make.left.equalTo(slowButton.snp.right)
                    make.right.equalTo(bottomMaskView.snp.right)
                }
            }
            fullScreenButton.setImage(JFImageResourcePath("JFPlayer_portialscreen"), for: UIControlState())
            chooseDefitionView.isHidden = false
            if JFPlayerConf.topBarShowInCase.rawValue == 2 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
            topMaskView.backgroundColor = maskViewColor
            titleLabel.isHidden = false
            backButton.isHidden = false
        } else {
            if JFPlayerConf.topBarShowInCase.rawValue >= 1 {
                topMaskView.isHidden = true
            } else {
                topMaskView.isHidden = false
            }
            chooseDefitionView.isHidden = true
            
            self.slowButton.isHidden = true
            self.mirrorButton.isHidden = true
            fullScreenButton.setImage(JFImageResourcePath("JFPlayer_fullscreen"), for: UIControlState())
            fullScreenButton.snp.remakeConstraints { (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.equalTo(currentTimeLabel)
                make.left.equalTo(totalTimeLabel.snp.right)
                make.right.equalTo(bottomMaskView.snp.right)
            }
            topMaskView.backgroundColor = UIColor(white: 0, alpha: 0.0)
            titleLabel.isHidden = true
            backButton.isHidden = true
        }
    }
    
    /**
     视频播放完成后 在视图中间显示一个 重播按钮
     */
    func showPlayToTheEndView() {
        centerButton.isHidden = false
    }
    
    /**
     显示正在缓冲动画
     */
    func showLoader() {
        loadingIndector.isHidden = false
        loadingIndector.startAnimating()
    }
    
    /**
     缓冲完成 隐藏缓存动画
     */
    func hideLoader() {
        loadingIndector.isHidden = true
    }
    
    /**
     显示 手势时间view
     
     - parameter toSecound: 需要播放的秒
     - parameter isAdd:     是快进还是快退
     */
    func showSeekToView(_ toSecound: TimeInterval, isAdd: Bool) {
        
        seekToView.isHidden = false
        let Min = Int(toSecound / 60)
        let Sec = Int(toSecound.truncatingRemainder(dividingBy: 60))
        seekToLabel.text = String(format: "%02d:%02d", Min, Sec)
        let rotate = isAdd ? 0 : CGFloat(M_PI)
        seekToViewImage.transform = CGAffineTransform(rotationAngle: rotate)
    }
    
    /**
     隐藏 手势时间view
     */
    func hideSeekToView() {
        seekToView.isHidden = true
    }
    
    /**
     显示封面图片
     
     - parameter cover: 封面图片的url字符串
     */
    func showCoverWithLink(_ cover:String) {
        if let url = URL(string: cover) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
                DispatchQueue.main.async(execute: {
                    self.maskImageView.image = UIImage(data: data!)
                    self.hideLoader()
                });
            }
        }
    }
    
    /**
     隐藏封面图片
     */
    func hideCoverImageView() {
        self.maskImageView.isHidden = true
    }
    
    /**
     选择清晰度
     
     - parameter items: <#items description#>
     - parameter index: <#index description#>
     */
    func prepareChooseDefinitionView(_ items: [JFPlayerItemDefinitionItem], index: Int) {
        self.videoItems = items
        for item in chooseDefitionView.subviews {
            item.removeFromSuperview()
        }
        
        for i in 0..<items.count {
            let button = JFPlayerClearityChooseButton()
            
            if i == 0 {
                button.tag = index
            } else if i <= index {
                button.tag = i - 1
            } else {
                button.tag = i
            }
            
            button.setTitle("\(items[button.tag].definitionName)", for: UIControlState())
            chooseDefitionView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControlEvents.touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.top.equalTo(chooseDefitionView.snp.top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(chooseDefitionView)
            })
            
            if items.count == 1 {
                button.isEnabled = false
            }
        }
    }
    
    /**
     已经选择了清晰度
     
     - parameter button: <#button description#>
     */
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {
        let height = isSelectecDefitionViewOpened ? 35 : videoItems.count * 40
        chooseDefitionView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) 
        isSelectecDefitionViewOpened = !isSelectecDefitionViewOpened
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlViewDidChooseDefition(button.tag)
        }
        prepareChooseDefinitionView(videoItems, index: selectedIndex)
    }
    
    /**
     重播
     */
    @objc fileprivate func onReplyButtonPressed() {
        centerButton.isHidden = true
        delegate?.controlViewDidPressOnReply()
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
        addSnapKitConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareUI()
        addSnapKitConstraint()
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        // 主体
        addSubview(mainMaskView)
        mainMaskView.addSubview(topMaskView)
        mainMaskView.addSubview(bottomMaskView)
        mainMaskView.insertSubview(maskImageView, at: 0)
        
        bottomMaskView.backgroundColor = maskViewColor
        
        // 顶部
        topMaskView.addSubview(backButton)
        topMaskView.addSubview(titleLabel)
        addSubview(chooseDefitionView)
        
        backButton.setImage(JFImageResourcePath("JFPlayer_back"), for: UIControlState())
        
        titleLabel.textColor = UIColor.white
        titleLabel.text      = ""
        titleLabel.font      = UIFont.systemFont(ofSize: 16)
        
        chooseDefitionView.clipsToBounds = true
        
        // 底部
        bottomMaskView.addSubview(playButton)
        bottomMaskView.addSubview(currentTimeLabel)
        bottomMaskView.addSubview(totalTimeLabel)
        bottomMaskView.addSubview(progressView)
        bottomMaskView.addSubview(timeSlider)
        bottomMaskView.addSubview(fullScreenButton)
        bottomMaskView.addSubview(mirrorButton)
        bottomMaskView.addSubview(slowButton)
        
        playButton.setImage(JFImageResourcePath("JFPlayer_play"), for: UIControlState())
        playButton.setImage(JFImageResourcePath("JFPlayer_pause"), for: UIControlState.selected)
        
        currentTimeLabel.textColor  = UIColor.white
        currentTimeLabel.font       = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.text       = "00:00"
        currentTimeLabel.textAlignment = NSTextAlignment.center
        
        totalTimeLabel.textColor    = UIColor.white
        totalTimeLabel.font         = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text         = "00:00"
        totalTimeLabel.textAlignment   = NSTextAlignment.center
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(JFImageResourcePath("JFPlayer_slider_thumb"), for: UIControlState())
        
        timeSlider.maximumTrackTintColor = UIColor.clear
        timeSlider.minimumTrackTintColor = JFPlayerConf.tintColor
        
        progressView.tintColor      = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6 )
        progressView.trackTintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3 )
        
        fullScreenButton.setImage(JFImageResourcePath("JFPlayer_fullscreen"), for: UIControlState())
        
        mirrorButton.layer.borderWidth = 1
        mirrorButton.layer.borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0).cgColor
        mirrorButton.layer.cornerRadius = 2.0
        mirrorButton.setTitle("镜像", for: UIControlState())
        mirrorButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        mirrorButton.isHidden = true
        
        slowButton.layer.borderWidth = 1
        slowButton.layer.borderColor = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0).cgColor
        slowButton.layer.cornerRadius = 2.0
        slowButton.setTitle("1.0X", for: UIControlState())
        slowButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        mirrorButton.isHidden = true
        
        // 中间
        mainMaskView.addSubview(loadingIndector)
        
//        loadingIndector.hidesWhenStopped = true
        loadingIndector.type             = JFPlayerConf.loaderType
        loadingIndector.color            = JFPlayerConf.tintColor
        
        
        // 滑动时间显示
        addSubview(seekToView)
        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToLabel)
        
        seekToLabel.font                = UIFont.systemFont(ofSize: 13)
        seekToLabel.textColor           = UIColor ( red: 0.9098, green: 0.9098, blue: 0.9098, alpha: 1.0 )
        seekToView.backgroundColor      = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        seekToView.layer.cornerRadius   = 4
        seekToView.layer.masksToBounds  = true
        seekToView.isHidden               = true
        
        seekToViewImage.image = JFImageResourcePath("JFPlayer_seek_to_image")
        
        self.addSubview(centerButton)
        centerButton.isHidden = true
        centerButton.setImage(JFImageResourcePath("JFPlayer_replay"), for: UIControlState())
        centerButton.addTarget(self, action: #selector(self.onReplyButtonPressed), for: UIControlEvents.touchUpInside)
    }
    
    /**
     添加UI
     */
    fileprivate func addSnapKitConstraint() {
        
        // 主体
        mainMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        maskImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(mainMaskView)
        }
        
        topMaskView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(mainMaskView)
            make.height.equalTo(65)
        }
        
        bottomMaskView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(mainMaskView)
            make.height.equalTo(50)
        }
        
        // 顶部
        backButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.bottom.equalTo(topMaskView)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right)
            make.centerY.equalTo(backButton)
        }
        
        chooseDefitionView.snp.makeConstraints { (make) in
            make.right.equalTo(topMaskView.snp.right).offset(-10)
            make.top.equalTo(titleLabel.snp.top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        // 底部
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.bottom.equalTo(bottomMaskView)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(playButton.snp.right)
            make.centerY.equalTo(playButton)
            make.width.equalTo(40)
        }
        
        timeSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(currentTimeLabel.snp.right).offset(10).priority(750)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.centerY.left.right.equalTo(timeSlider)
            make.height.equalTo(2)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(timeSlider.snp.right).offset(5)
            make.width.equalTo(40)
        }
        
        mirrorButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.left.equalTo(totalTimeLabel.snp.right).offset(10)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        slowButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.left.equalTo(mirrorButton.snp.right).offset(10)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        fullScreenButton.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerY.equalTo(currentTimeLabel)
            make.left.equalTo(totalTimeLabel.snp.right)
            make.right.equalTo(bottomMaskView.snp.right)
        }
        
        // 中间
        loadingIndector.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX).offset(-15)
            make.centerY.equalTo(mainMaskView.snp.centerY).offset(-15)
        }
        
        seekToView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        seekToViewImage.snp.makeConstraints { (make) in
            make.left.equalTo(seekToView.snp.left).offset(15)
            make.centerY.equalTo(seekToView.snp.centerY)
            make.height.equalTo(15)
            make.width.equalTo(25)
        }
        
        seekToLabel.snp.makeConstraints { (make) in
            make.left.equalTo(seekToViewImage.snp.right).offset(10)
            make.centerY.equalTo(seekToView.snp.centerY)
        }
        
        centerButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(mainMaskView.snp.centerX)
            make.centerY.equalTo(mainMaskView.snp.centerY)
            make.width.height.equalTo(50)
        }
        
    }
    
    /**
     创建UIImage
     */
    fileprivate func JFImageResourcePath(_ fileName: String) -> UIImage? {
        return UIImage(named: fileName)
    }
}

/// 时间滑条
open class JFTimeSlider: UISlider {
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let trackHeigt:CGFloat = 2
        let position = CGPoint(x: 0 , y: 14)
        let customBounds = CGRect(origin: position, size: CGSize(width: bounds.size.width, height: trackHeigt))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newx = rect.origin.x - 10
        let newRect = CGRect(x: newx, y: 0, width: 30, height: 30)
        return newRect
    }
}
