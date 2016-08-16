//
//  JFTweetViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTweetViewController: UIViewController {

    /// 当前页码
    var page: Int = 0
    
    /// 动弹模型数组
    var tweets = [JFTweet]()
    
    /// 动弹列表cell重用标识
    let tweetIdentifier = "tweetIdentifier"
    
    /// 加载类型 / 最新new 最热hot 我的me
    var type = "new"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = COLOR_ALL_BG
        
        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        tableView.mj_header.beginRefreshing()
        
        // 监听点击图片的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JFTweetViewController.selectedPicture(_:)), name: JFStatusPictureViewCellSelectedPictureNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: JFStatusPictureViewCellSelectedPictureNotification, object: nil)
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
        
        JFTweet.loadTrendsList(type, page: page, user_id: JFAccountModel.shareAccount()?.id ?? 0) { (tweets) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let tweets = tweets else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.tweets = tweets
            } else {
                self.tweets += tweets
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
        tableView.registerClass(JFTweetListCell.classForCoder(), forCellReuseIdentifier: self.tweetIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFTweetViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let tweet = tweets[indexPath.row]
        if Int(tweet.rowHeight) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(tweetIdentifier) as! JFTweetListCell
            let height = cell.getRowHeight(tweet)
            tweet.rowHeight = height
        }
        return tweet.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetIdentifier) as! JFTweetListCell
        cell.tweet = tweets[indexPath.row]
        cell.tweetListCellDelegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let detailVc = JFTweetDetailViewController()
        detailVc.tweet = tweets[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}

// MARK: - JFTweetsListCellDelegate - JFStatusPictureViewCellSelectedPictureNotification
extension JFTweetViewController: JFTweetListCellDelegate {
    
    /**
     点击了 头像
     */
    func tweetListCell(cell: JFTweetListCell, didTappedAvatarButton button: UIButton) {
        print("user_id = ", cell.tweet?.author?.id ?? 0)
    }
    
    /**
     点击了 赞按钮
     */
    func tweetListCell(cell: JFTweetListCell, didTappedLikeButton button: UIButton) {
        print(cell.tweet?.id)
    }
    
    /**
     点击了 超链接
     */
    func tweetListCell(cell: JFTweetListCell, didTappedSuperLink url: String) {
        print(cell.tweet?.id, url)
    }
    
    /**
     点击了 @昵称
     */
    func tweetListCell(cell: JFTweetListCell, didTappedAtUser nickname: String, sequence: Int) {
        
        guard let atUsers = cell.tweet?.atUsers else {
            return
        }
        
        for atUser in atUsers {
            if atUser.nickname == nickname && atUser.sequence == sequence {
                print("user_id = ", atUser.id)
            }
        }
        
    }
    
    // MARK: - 做转场动画
    /**
     选择了动弹配图
     */
    func selectedPicture(notification: NSNotification) {
        guard let models = notification.userInfo?[JFStatusPictureViewCellSelectedPictureModelKey] as? [JFPhotoBrowserModel] else {
            return
        }
        guard let index = notification.userInfo?[JFStatusPictureViewCellSelectedPictureIndexKey] as? Int else {
            return
        }
        
        let photoBrowserVC = JFPhotoBrowserViewController(models: models, selectedIndex: index)
        photoBrowserVC.transitioningDelegate = photoBrowserVC
        photoBrowserVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(photoBrowserVC, animated: true, completion: nil)
    }
}
