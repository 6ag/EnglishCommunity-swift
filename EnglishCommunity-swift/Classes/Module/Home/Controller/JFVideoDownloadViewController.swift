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
    fileprivate func prepareUI() {
        
        view.addSubview(topStoreInfoView)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        topStoreInfoView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(114)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(topStoreInfoView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(50)
        }
        
    }

    // MARK: - 懒加载
    /// 顶部存储信息视图
    lazy var topStoreInfoView: JFTopStoreInfoView = {
        let view = Bundle.main.loadNibNamed("JFTopStoreInfoView", owner: nil, options: nil)?.last as! JFTopStoreInfoView
        view.delegate = self
        return view
    }()
    
    /// 底部工具条
    lazy var bottomView: JFVideoDownloadBottomView = {
        let view = Bundle.main.loadNibNamed("JFVideoDownloadBottomView", owner: nil, options: nil)?.last as! JFVideoDownloadBottomView
        view.delegate = self
        return view
    }()
    
    /// 视频播放列表
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.register(JFVideoDownloadCell.classForCoder(), forCellReuseIdentifier: self.videoDownloadCellIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension JFVideoDownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.videoDownloadCellIdentifier) as! JFVideoDownloadCell
        cell.video = videos![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! JFVideoDownloadCell
        cell.selectorButton.isSelected = !cell.selectorButton.isSelected
        videos![indexPath.row].downloadListSelected = cell.selectorButton.isSelected
    }

}

// MARK: - JFTopStoreInfoViewDelegate
extension JFVideoDownloadViewController: JFTopStoreInfoViewDelegate {
    
    /**
     点击了顶部关闭按钮
     */
    func didTappedCloseButton(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - JFVideoDownloadBottomViewDelegate
extension JFVideoDownloadViewController: JFVideoDownloadBottomViewDelegate {
    
    /**
     点击了选择按钮
     */
    func didTappedSelectButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            // 全选
            for video in videos! {
                video.downloadListSelected = true
            }
        } else {
            // 取消全选
            for video in videos! {
                video.downloadListSelected = false
            }
        }
        
        tableView.reloadData()
    }
    
    /**
     点击了确定按钮
     */
    func didTappedConfirmButton(_ button: UIButton) {
        
        var needVideos = [[String : AnyObject]]()
        for (index, video) in videos!.enumerated() {
            if video.downloadListSelected && video.state == VideoState.noDownload {
                
                let info: [String : AnyObject] = [
                    "index" : index as AnyObject,
                    "video" : video
                ]
                needVideos.append(info)
                
                video.downloadListSelected = false
            }
        }
        
        // 开始下载视频
        JFDownloadManager.shareManager.startDownload(videoInfo!.id, needVideos: needVideos)
        
        dismiss(animated: true) {}
        
    }
}
