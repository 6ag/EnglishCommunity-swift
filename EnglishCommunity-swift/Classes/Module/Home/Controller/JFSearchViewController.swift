//
//  JFSearchViewController.swift
//  LiuAGeIOS
//
//  Created by zhoujianfeng on 16/6/24.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SnapKit

class JFSearchViewController: UIViewController {
    
    /// 当前页码
    var pageIndex = 0
    
    /// 搜索视频信息数组模型
    var videoInfos = [JFVideoInfo]()
    
    /// 重用标识
    let videoListIdentifier = "videoListIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        searchTextField.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        view.backgroundColor = COLOR_ALL_BG
        navigationItem.titleView = searchTextField
        view.addSubview(tableView)
    }
    
    /**
     准备tableView
     */
    private func prepareTableView() {
        view.addSubview(tableView)
    }
    
    /**
     上拉加载更多数据
     */
    @objc private func loadMoreData() {
        pageIndex += 1
        loadSearchResult(searchTextField.text!, pageIndex: pageIndex)
    }
    
    /**
     加载搜索结果
     
     - parameter keyword:  关键词
     - parameter pageIndex: 页码
     */
    
    private func loadSearchResult(keyword: String, pageIndex: Int) {
        
        JFVideoInfo.searchVideoInfoList(keyword, page: pageIndex) { (videoInfos) in
            self.tableView.mj_footer.endRefreshing()
            
            guard let videoInfos = videoInfos else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                self.tableView.reloadData()
                return
            }
            
            self.videoInfos += videoInfos
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - 懒加载
    /// 搜索框
    private lazy var searchTextField: UISearchBar = {
        let searchTextField = UISearchBar(frame: CGRect(x: 20, y: 5, width: SCREEN_WIDTH - 40, height: 34))
        searchTextField.searchBarStyle = .Prominent
        searchTextField.delegate = self
        searchTextField.placeholder = "请输入课程关键词"
        return searchTextField
    }()
    
    // MARK: - 懒加载
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerNib(UINib(nibName: "JFCategoryListCell", bundle: nil), forCellReuseIdentifier: self.videoListIdentifier)
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
        return tableView
    }()
    
}

// MARK: - UISearchBarDelegate
extension JFSearchViewController: UISearchBarDelegate {
    
    // 已经改变搜索文字
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    // 点击了搜索按钮
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTextField.endEditing(true)
        self.videoInfos.removeAll()
        loadMoreData()
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoInfos.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(videoListIdentifier) as! JFCategoryListCell
        cell.videoInfo = videoInfos[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = videoInfos[indexPath.item]
        navigationController?.pushViewController(playerVc, animated: true)
    }
}
