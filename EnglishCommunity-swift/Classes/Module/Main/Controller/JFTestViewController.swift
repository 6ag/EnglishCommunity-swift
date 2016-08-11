import UIKit
import SnapKit
import NVActivityIndicatorView

class JFTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        resetPlayerManager()
        
        player.playWithURL(NSURL(string: "http://www.temp.com/1.mkv")!)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(player)
        
        player.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(view.snp_width).multipliedBy(9.0 / 16.0)
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
    
    // MARK: - 懒加载
    /// 播放器
    lazy var player: JFPlayer = {
        let player = JFPlayer()
        player.delegate = self
        return player
    }()
    
}

// MARK: - JFPlayerDelegate
extension JFTestViewController: JFPlayerDelegate {
    
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
