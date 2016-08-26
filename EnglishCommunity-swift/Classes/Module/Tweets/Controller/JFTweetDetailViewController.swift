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
    
    /// 即将回复的评论
    var revertComment: JFComment?
    
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
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        view.addSubview(multiTextView)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData("tweet", page: page, method: 1, source_id: tweet!.id)
    }
    
    /**
     更新评论数据
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
        tweetDetailHeaderView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: self.tweet!.rowHeight)
        tweetDetailHeaderView.tweet = self.tweet
        tweetDetailHeaderView.tweetDetailHeaderDelegate = self
        return tweetDetailHeaderView
    }()

    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 40), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerNib(UINib(nibName: "JFCommentCell", bundle: nil), forCellReuseIdentifier: self.commentIdentifier)
        return tableView
    }()
    
    /// 评论文本框
    lazy var multiTextView: JFMultiTextView = {
        let textView = JFMultiTextView()
        textView.haveNavigationBar = true
        textView.delegate = self
        return textView
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
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 即将回复的评论
        revertComment = comments[indexPath.row]
        
        // 弹出键盘并获得第一响应者
        multiTextView.expansion()
        multiTextView.placeholderString = "@\(revertComment!.author!.nickname!) "
    }
    
}

// MARK: - JFCommentCellDelegate
extension JFTweetDetailViewController: JFCommentCellDelegate {
    
    func commentCell(cell: JFCommentCell, didTappedAtUser nickname: String, sequence: Int) {
        guard let atUser = cell.comment?.extendsAuthor else {
            return
        }
        
        if atUser.nickname == nickname {
            let otherUser = JFOtherUserViewController()
            otherUser.userId = atUser.id
            navigationController?.pushViewController(otherUser, animated: true)
        }
    }
    
    func commentCell(cell: JFCommentCell, didTappedAvatarButton button: UIButton) {
        guard let author = cell.comment?.author else {
            return
        }
        
        let otherUser = JFOtherUserViewController()
        otherUser.userId = author.id
        navigationController?.pushViewController(otherUser, animated: true)
    }
}

// MARK: - JFTweetDetailHeaderViewDelegate
extension JFTweetDetailViewController: JFTweetDetailHeaderViewDelegate {
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedAvatarButton button: UIButton) {
        
        guard let author = headerView.tweet?.author else {
            return
        }
        
        let otherUser = JFOtherUserViewController()
        otherUser.userId = author.id
        navigationController?.pushViewController(otherUser, animated: true)
    }
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedLikeButton button: UIButton) {
        // 未登录
        if !JFAccountModel.isLogin() {
            presentViewController(JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil)), animated: true, completion: nil)
            return
        }
        
        // 已经登录
        JFNetworkTools.shareNetworkTool.addOrCancelLikeRecord("tweet", sourceID: headerView.tweet!.id) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                return
            }
            
            if result["result"]["type"].stringValue == "add" {
                // 赞
                headerView.tweet!.likeCount += 1
                headerView.tweet!.liked = 1
            } else {
                // 取消赞
                headerView.tweet!.likeCount -= 1
                headerView.tweet!.liked = 0
            }
            
            // 刷新UI
            headerView.getRowHeight(headerView.tweet!)
        }
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
                let otherUser = JFOtherUserViewController()
                otherUser.userId = atUser.id
                navigationController?.pushViewController(otherUser, animated: true)
            }
        }
    }
}

// MARK: - JFMultiTextViewDelegate
extension JFTweetDetailViewController: JFMultiTextViewDelegate {
    
    /**
     点击了键盘发送按钮
     
     - parameter text: 输入的内容
     */
    func didTappedSendButton(text: String) {
        
        let pid = revertComment?.id ?? 0
        revertComment = nil
        
        if isLogin(self) {
            JFComment.publishComment("tweet", sourceId: tweet!.id, content: text, pid: pid, finished: { (success) in
                if success {
                    self.updateData("tweet", page: 1, method: 0, source_id: self.tweet!.id)
                }
            })
        }
        
    }
}

