//
//  JFTrendsViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTrendsViewController: UIViewController {

    /// 当前页码
    var page: Int = 0
    
    /// 动弹模型数组
    var trendsArray = [JFTrends]()
    
    /// 动弹列表cell重用标识
    let trendsIdentifier = "trendsIdentifier"
    
    /// 加载类型 / 最新new 最热hot 我的me
    var type = "new"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = COLOR_ALL_BG
        
        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        tableView.mj_header.beginRefreshing()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        prepareNavigationBar()
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
    }
    
    /**
     准备导航栏
     */
    private func prepareNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem("", highlightedImage: "", target: self, action: #selector(didTappedRightBarButton(_:)))
    }
    
    /**
     点击了右边按钮
     */
    @objc private func didTappedRightBarButton(barButtonItem: UIBarButtonItem) {
        navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
    /**
     下拉刷新
     */
    @objc private func pullDownRefresh() {
        page = 1
        updateData(type, page: page, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData(type, page: page, method: 1)
    }
    
    /**
     更新数据
     */
    private func updateData(type: String, page: Int, method: Int) {
        
        JFTrends.loadTrendsList(type, page: page, user_id: JFAccountModel.shareAccount()?.id ?? 0) { (trendsArray) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let trendsArray = trendsArray else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.trendsArray = trendsArray
            } else {
                self.trendsArray += trendsArray
            }
            
            self.tableView.reloadData()
        }
    }

    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerNib(UINib(nibName: "JFTrendsListCell", bundle: nil), forCellReuseIdentifier: self.trendsIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFTrendsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let trends = trendsArray[indexPath.row]
        if Int(trends.rowHeight) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(trendsIdentifier) as! JFTrendsListCell
            let height = cell.getRowHeight(trends)
            trends.rowHeight = height
        }
        return trends.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(trendsIdentifier) as! JFTrendsListCell
        cell.trends = trendsArray[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVc = JFTrendsDetailViewController()
        detailVc.trends = trendsArray[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}
