//
//  JFVideoDownloadViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFVideoDownloadViewController: UIViewController {

    /// 视频列表模型数组
    var videos: [JFVideo]? {
        didSet {
            guard videos != nil else {
                return
            }
            prepareUI()
        }
    }
    
    /// 视频信息模型
    var videoInfo: JFVideoInfo?
    
    /// 视频列表评论标识
    let videoDownloadCellIdentifier = "videoDownloadCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.addSubview(topStoreInfoView)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        topStoreInfoView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(114)
        }
        
        tableView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(topStoreInfoView.snp_bottom)
            make.bottom.equalTo(bottomView.snp_top)
        }
        
        bottomView.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(50)
        }
        
    }

    // MARK: - 懒加载
    /// 顶部存储信息视图
    lazy var topStoreInfoView: JFTopStoreInfoView = {
        let view = NSBundle.mainBundle().loadNibNamed("JFTopStoreInfoView", owner: nil, options: nil).last as! JFTopStoreInfoView
        view.delegate = self
        return view
    }()
    
    /// 底部工具条
    lazy var bottomView: JFVideoDownloadBottomView = {
        let view = NSBundle.mainBundle().loadNibNamed("JFVideoDownloadBottomView", owner: nil, options: nil).last as! JFVideoDownloadBottomView
        view.delegate = self
        return view
    }()
    
    /// 视频播放列表
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        tableView.registerClass(JFVideoDownloadCell.classForCoder(), forCellReuseIdentifier: self.videoDownloadCellIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFVideoDownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.videoDownloadCellIdentifier) as! JFVideoDownloadCell
        cell.video = videos![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! JFVideoDownloadCell
        cell.selectorButton.selected = !cell.selectorButton.selected
        videos![indexPath.row].selected = cell.selectorButton.selected
    }

}

// MARK: - JFTopStoreInfoViewDelegate
extension JFVideoDownloadViewController: JFTopStoreInfoViewDelegate {
    
    /**
     点击了顶部关闭按钮
     */
    func didTappedCloseButton(button: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - JFVideoDownloadBottomViewDelegate
extension JFVideoDownloadViewController: JFVideoDownloadBottomViewDelegate {
    
    /**
     点击了选择按钮
     */
    func didTappedSelectButton(button: UIButton) {
        button.selected = !button.selected
        
        if button.selected {
            // 全选
            for video in videos! {
                video.selected = true
            }
        } else {
            // 取消全选
            for video in videos! {
                video.selected = false
            }
        }
        
        tableView.reloadData()
    }
    
    /**
     点击了确定按钮
     */
    func didTappedConfirmButton(button: UIButton) {
        
        var needVideos = [JFVideo]()
        for video in videos! {
            if video.selected {
                needVideos.append(video)
                video.selected = false
            }
        }
        
        dismissViewControllerAnimated(true) { 
            JFProgressHUD.showInfoWithStatus("暂未开放")
        }
        
        // 开始下载视频
//        JFDownloadManager.shareManager.startDownloadVideo(videoInfo!, videos: videos!)
//        
//        dismissViewControllerAnimated(true) { 
//            JFProgressHUD.showInfoWithStatus("已经加入下载队列")
//        }
        
    }
}
