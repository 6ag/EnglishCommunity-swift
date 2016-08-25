//
//  JFCategoryViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFCategoryViewController: UIViewController {
    
    var page: Int = 0
    
    var videoInfos = [JFVideoInfo]()
    
    let categoryIdentifier = "JFCategoryCell"
    
    var category: JFVideoCategory? {
        didSet {
            title = category!.name!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        tableView.mj_header.beginRefreshing()
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
        view.addSubview(tableView)
    }
    
    /**
     下拉刷新
     */
    @objc private func pullDownRefresh() {
        page = 1
        updateData(category!.id, page: page, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData(category!.id, page: page, method: 1)
    }
    
    /**
     更新数据
     
     - parameter category_id: 分类id
     */
    private func updateData(category_id: Int, page: Int, method: Int) {
        
        JFVideoInfo.loadVideoInfoList(page, count: 10, category_id: category_id, recommend: 0) { (videoInfos) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let videoInfos = videoInfos else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            // 下拉
            if (method == 0) {
                self.videoInfos = videoInfos
            } else {
                self.videoInfos += videoInfos
            }
            
            self.tableView.reloadData()
            
        }
    }

    // MARK: - 懒加载
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.rowHeight = 84
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerNib(UINib(nibName: "JFCategoryListCell", bundle: nil), forCellReuseIdentifier: self.categoryIdentifier)
        return tableView
    }()
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoInfos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(categoryIdentifier) as! JFCategoryListCell
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
