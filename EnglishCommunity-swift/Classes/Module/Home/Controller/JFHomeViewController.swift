//
//  JFHomeViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh
import SwiftyJSON

class JFHomeViewController: UIViewController {
    
    let categoriesIdentifier = "categoriesIdentifier"
    let homeCellIdentifier = "homeCellIdentifier"
    
    /// 顶部轮播视图
    var topScrollView: SDCycleScrollView?
    var topVideoInfos = [JFVideoInfo]()
    
    /// 所有分类信息模型
    var videoCategories = [JFVideoCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateHomeData))
        loadTopData()
        loadCategoriesData()
        
        // 配置JPUSH
        (UIApplication.shared.delegate as! AppDelegate).setupJPush()
        // 注册接收推送通知的通知
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRemoteNotificationOfJPush(_:)), name: NSNotification.Name(rawValue: JFDidReceiveRemoteNotificationOfJPush), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        topScrollView?.adjustWhenControllerViewWillAppera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAppstoreTip()
    }
    
    /**
     弹出提示让用户去评论
     */
    fileprivate func showAppstoreTip() {
        
        // 在当前时间往后的1天后提示
        let tipTime = UserDefaults.standard.double(forKey: "tipToAppstore")
        
        // 设置第一次弹出提示的时间
        if tipTime < 1 {
            UserDefaults.standard.set(Date().timeIntervalSince1970 + 86400, forKey: "tipToAppstore")
        }
        
        // 当前时间超过了规定时间就弹出提示
        let nowTime = Date().timeIntervalSince1970
        if nowTime > TimeInterval(UserDefaults.standard.double(forKey: "tipToAppstore")) {
            let appstore = LBToAppStore()
            appstore.myAppID = APPLE_ID
            appstore.showGotoAppStore(self)
        }
        
    }
    
    /**
     处理接收到的远程通知处理
     */
    func didReceiveRemoteNotificationOfJPush(_ notification: Notification) {
        JPUSHService.resetBadge()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        guard let userInfo = notification.userInfo as? [String : AnyObject] else {
            return
        }
        
        guard let id = userInfo["id"] as? String else {
            return
        }
        
        let videoInfoId = Int(id)!
        
        if videoInfoId != -1 {
            JFProgressHUD.showWithStatus("正在加载")
            JFVideoInfo.loadVideoInfoDetail(videoInfoId, finished: { (videoInfo) in
                JFProgressHUD.dismiss()
                guard let videoInfo = videoInfo else {
                    return
                }
                
                let playerVc = JFPlayerViewController()
                playerVc.videoInfo = videoInfo
                self.navigationController?.pushViewController(playerVc, animated: true)
            })
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        view.backgroundColor = COLOR_ALL_BG
        tableView.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem("navigation_search_icon", highlightedImage: "navigation_search_icon_selected", target: self, action: #selector(didTappedSearchButton))
    }
    
    /**
     准备顶部轮播
     */
    fileprivate func prepareScrollView() {
        
        topScrollView = SDCycleScrollView(frame: CGRect(x:0, y:0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.3), delegate: self, placeholderImage: UIImage(named: "photoview_image_default_white"))
        topScrollView?.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter
        topScrollView?.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated
        
        var images = [String]()
        for model in topVideoInfos {
            images.append(model.cover!)
        }
        
        topScrollView?.imageURLStringsGroup = images
        topScrollView?.autoScrollTimeInterval = 5
        tableView.tableHeaderView = topScrollView
    }
    
    /**
     点击了搜索按钮
     */
    @objc fileprivate func didTappedSearchButton() {
        navigationController?.pushViewController(JFSearchViewController(), animated: true)
    }
    
    /**
     刷新首页数据
     */
    @objc fileprivate func updateHomeData() {
        
        // 有网络的情况下清理掉缓存
        if JFNetworkTools.shareNetworkTool.getCurrentNetworkState() != 0 {
            removeJson(BANNER_JSON_PATH)
            removeJson(CATEGORIES_JSON_PATH)
        }
        
        loadTopData()
        loadCategoriesData()
    }
    
    /**
     加载顶部轮播数据
     */
    fileprivate func loadTopData() {
        
        JFVideoInfo.loadVideoInfoList(1, count: 4, category_id: 0, recommend: 1) { (videoInfos) in
            guard let videoInfos = videoInfos else {
                return
            }
            
            self.topVideoInfos = videoInfos
            self.prepareScrollView()
            
        }
    }
    
    /**
     加载所有分类数据
     */
    fileprivate func loadCategoriesData() {
        
        JFVideoCategory.loadAllCategories(1, count: 4) { (videoCategories) in
            
            self.tableView.mj_header.endRefreshing()
            
            guard let videoCategories = videoCategories else {
                return
            }
            
            self.videoCategories = videoCategories
            self.tableView.reloadData()
        }
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.separatorColor = UIColor(red:0.9,  green:0.9,  blue:0.9, alpha:1)
        tableView.register(JFCategoriesCell.self, forCellReuseIdentifier: self.categoriesIdentifier)
        tableView.register(JFHomeCell.self, forCellReuseIdentifier: self.homeCellIdentifier)
        return tableView
    }()
    
}

// MARK: - SDCycleScrollViewDelegate
extension JFHomeViewController: SDCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        
        // 进入播放页面
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = topVideoInfos[index]
        navigationController?.pushViewController(playerVc, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 分类 + 1个分类综合
        return videoCategories.count > 0 ? videoCategories.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return SCREEN_WIDTH * 0.2
        } else {
            return LIST_ITEM_HEIGHT * 2 + LIST_ITEM_PADDING
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let headerView = Bundle.main.loadNibNamed("JFHomeSectionHeaderView", owner: nil, options: nil)?.last as! JFHomeSectionHeaderView
            headerView.titleLabel.text = videoCategories[section - 1].name
            headerView.section = section
            headerView.delegate = self
            headerView.moreButton.isHidden = false
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: categoriesIdentifier) as! JFCategoriesCell
            cell.delegate = self
            cell.videoCategories = videoCategories
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: homeCellIdentifier) as! JFHomeCell
            cell.videoCategory = videoCategories[indexPath.section - 1]
            cell.delegate = self
            return cell
        }
    }
    
}

// MARK: - JFCategoriesCellDelegate, JFHomeCellDelegate
extension JFHomeViewController: JFCategoriesCellDelegate, JFHomeCellDelegate {
    
    /**
     点击了顶部横向滑动分类的item
     
     - parameter cell:      所在的cell
     - parameter indexPath: 点击的cell内部collectionView的indexPath
     */
    func categoriesCell(_ cell: UITableViewCell, didSelectItemAtIndexPath indexPath: IndexPath) {
        let categoryVc = JFCategoryViewController()
        categoryVc.category = videoCategories[indexPath.row]
        navigationController?.pushViewController(categoryVc, animated: true)
    }
    
    /**
     点击了首页视频的item
     
     - parameter cell:      所在的cell
     - parameter indexPath: 点击的cell内部collectionView的indexPath
     */
    func homeCell(_ cell: UITableViewCell, didSelectItemAtIndexPath indexPath: IndexPath) {
        let cellIndexPath = tableView.indexPath(for: cell)!
        
        // 进入播放页面
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = videoCategories[cellIndexPath.section - 1].videoInfos![indexPath.item]
        navigationController?.pushViewController(playerVc, animated: true)
    }
    
}

// MARK: - JFHomeSectionHeaderViewDelegate
extension JFHomeViewController: JFHomeSectionHeaderViewDelegate {
    
    /**
     点击了更多按钮
     */
    func didTappedMoreButton(_ section: Int) {
        let categoryVc = JFCategoryViewController()
        categoryVc.category = videoCategories[section - 1]
        navigationController?.pushViewController(categoryVc, animated: true)
    }
}

