//
//  JFTweetsViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFTweetsViewController: UIViewController {

    /// 当前页码
    var page: Int = 0
    
    /// 动弹模型数组
    var tweetsArray = [JFTweets]()
    
    /// 动弹列表cell重用标识
    let tweetsIdentifier = "tweetsIdentifier"
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JFTweetsViewController.selectedPicture(_:)), name: JFStatusPictureViewCellSelectedPictureNotification, object: nil)
    }
    
    /// 配图视图 cell 点击的 处理方法
    func selectedPicture(notification: NSNotification) {
        guard let models = notification.userInfo?[JFStatusPictureViewCellSelectedPictureModelKey] as? [JFPhotoBrowserModel] else {
            print("models有问题")
            return
        }
        
        guard let index = notification.userInfo?[JFStatusPictureViewCellSelectedPictureIndexKey] as? Int else {
            print("index有问题")
            return
        }
        
        let photoBrowserVC = JFPhotoBrowserViewController(models: models, selectedIndex: index)
        photoBrowserVC.transitioningDelegate = photoBrowserVC
        photoBrowserVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(photoBrowserVC, animated: true, completion: nil)
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
        
        JFTweets.loadTrendsList(type, page: page, user_id: JFAccountModel.shareAccount()?.id ?? 0) { (tweetsArray) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let tweetsArray = tweetsArray else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.tweetsArray = tweetsArray
            } else {
                self.tweetsArray += tweetsArray
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
        tableView.registerClass(JFTweetsListCell.classForCoder(), forCellReuseIdentifier: self.tweetsIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFTweetsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let tweets = tweetsArray[indexPath.row]
        if Int(tweets.rowHeight) == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(tweetsIdentifier) as! JFTweetsListCell
            let height = cell.getRowHeight(tweets)
            tweets.rowHeight = height
        }
        return tweets.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetsIdentifier) as! JFTweetsListCell
        cell.tweets = tweetsArray[indexPath.row]
        cell.tweetsListCellDelegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let detailVc = JFTweetsDetailViewController()
        detailVc.tweets = tweetsArray[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}

// MARK: - JFTweetsListCellDelegate
extension JFTweetsViewController: JFTweetsListCellDelegate {
    
    /**
     点击了头像
     
     - parameter cell:   动弹列表cell
     - parameter button: 被点击的按钮
     */
    func tweetsListCell(cell: JFTweetsListCell, didTappedAvatarButton button: UIButton) {
        print(cell.tweets?.author?.nickname)
    }
    
    /**
     点击了赞
     
     - parameter cell:   动弹列表cell
     - parameter button: 被点击的按钮
     */
    func tweetsListCell(cell: JFTweetsListCell, didTappedLikeButton button: UIButton) {
        print(cell.tweets?.id)
    }
}
