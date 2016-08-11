//
//  JFTrendsDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTrendsDetailViewController: UIViewController {
    
    /// 当前页码
    var page: Int = 1
    
    /// 评论重用cell
    let commentIdentifier = "commentIdentifier"
    
    /// 准备列表
    var comments = [JFComment]()
    
    /// 动弹模型
    var trends: JFTrends?

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        updateData("trends", page: page, method: 0, source_id: trends!.id)
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        title = "动态详情"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData("trends", page: page, method: 1, source_id: trends!.id)
    }
    
    /**
     更新数据
     */
    private func updateData(type: String, page: Int, method: Int, source_id: Int) {
        
        JFComment.loadCommentList(page, type: type, source_id: source_id) { (comments) in
            
            self.tableView.mj_footer.endRefreshing()
            
            guard let comments = comments else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.comments = comments
            } else {
                self.comments += comments
            }
            
            self.tableView.reloadData()
        }
        
    }

    
    /// 动弹内容区域
    lazy var headerView: JFTrendsDetailHeaderView = {
        let trendsDetailView = NSBundle.mainBundle().loadNibNamed("JFTrendsDetailHeaderView", owner: nil, options: nil).last as! JFTrendsDetailHeaderView
        trendsDetailView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: trendsDetailView.getRowHeight(self.trends!))
        return trendsDetailView
    }()

    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentIdentifier)
        return tableView
    }()

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFTrendsDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let comment = comments[indexPath.row]
        if Int(comment.rowHeight) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(commentIdentifier) as! JFCommentCell
            let height = cell.getRowHeight(comment)
            comment.rowHeight = height
        }
        return comment.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commentIdentifier) as! JFCommentCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }
    
}

