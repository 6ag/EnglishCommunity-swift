//
//  JFTweetDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTweetDetailViewController: UIViewController {
    
    /// 当前页码
    var page: Int = 1
    
    /// 评论重用cell
    let commentIdentifier = "commentIdentifier"
    
    /// 准备列表
    var comments = [JFComment]()
    
    /// 动弹模型
    var tweet: JFTweet?

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        updateData("tweet", page: page, method: 0, source_id: tweet!.id)
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
        updateData("tweet", page: page, method: 1, source_id: tweet!.id)
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
    lazy var headerView: JFTweetDetailHeaderView = {
        let tweetDetailHeaderView = JFTweetDetailHeaderView()
        tweetDetailHeaderView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: tweetDetailHeaderView.getRowHeight(self.tweet!))
        tweetDetailHeaderView.tweetDetailHeaderDelegate = self
        return tweetDetailHeaderView
    }()

    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentIdentifier)
        return tableView
    }()

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFTweetDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
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

// MARK: - JFTweetDetailHeaderViewDelegate
extension JFTweetDetailViewController: JFTweetDetailHeaderViewDelegate {
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedAvatarButton button: UIButton) {
        print("user_id = ", headerView.tweet?.author?.id ?? 0)
    }
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedLikeButton button: UIButton) {
        print(headerView.tweet?.id)
    }
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedSuperLink url: String) {
        print(headerView.tweet?.id, url)
    }
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedAtUser nickname: String, sequence: Int) {
        
        guard let atUsers = headerView.tweet?.atUsers else {
            return
        }
        
        for atUser in atUsers {
            if atUser.nickname == nickname && atUser.sequence == sequence {
                print("user_id = ", atUser.id)
            }
        }
    }
}

