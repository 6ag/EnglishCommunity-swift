//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

class JFProfileViewController: UIViewController {
    
    /// 图片选择控制器
    let imagePickerC = UIImagePickerController()
    
    /// 头部高度
    let headerHeight = SCREEN_HEIGHT * 0.4
    
    /// 收藏cell重用标识
    let collectionIdentifier = "collectionIdentifier"
    
    /// 当前收藏的页码
    var page: Int = 1
    
    /// 视频信息模型数组
    var videoInfos = [JFVideoInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        // 配置上拉加载
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // 更新头部信息
        updateHeaderData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateData()
    }
    
    /**
     准备tableView
     */
    private func prepareUI() {
        
        view.addSubview(tableView)
        view.addSubview(navigationBarView)
        tableView.addSubview(placeholderButton)
        
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: headerHeight))
        placeholderView.userInteractionEnabled = false
        tableView.tableHeaderView = placeholderView
        tableView.addSubview(headerView)
        
        navigationBarView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.size.equalTo(CGSize(width: SCREEN_WIDTH, height: 64))
        }
        
        placeholderButton.snp_makeConstraints { (make) in
            make.centerX.equalTo(tableView)
            make.centerY.equalTo(tableView).offset(40)
            make.size.equalTo(CGSize(width: SCREEN_WIDTH - 50, height: 150))
        }
        
        changePlaceholderButton()
    }
    
    /**
     更新数据
     */
    private func updateData() {
        
        // 更新收藏
        page = 1
        loadCollectionVideoInfoList(page, count: 10, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        loadCollectionVideoInfoList(page, count: 10, method: 1)
    }
    
    /**
     加载指定用户的收藏数据
     
     - parameter page:  页码
     - parameter count: 每页数量
     */
    private func loadCollectionVideoInfoList(page: Int, count: Int, method: Int) {
        
        if !JFAccountModel.isLogin() {
            self.changePlaceholderButton()
            return
        }
        
        JFVideoInfo.loadCollectionVideoInfoList(page, count: count) { (videoInfos) in
            
            self.tableView.mj_footer.endRefreshing()
            
            guard let videoInfos = videoInfos else {
                self.changePlaceholderButton()
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.videoInfos = videoInfos
            } else {
                self.videoInfos += videoInfos
            }
            
            self.tableView.reloadData()
            self.changePlaceholderButton()
        }
    }
    
    /**
     更新头部数据
     */
    private func updateHeaderData() {
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatar!), forState: UIControlState.Normal, options: YYWebImageOptions(rawValue: 0))
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname!
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
            headerView.nameLabel.text = "点击登录"
        }
    }
    
    /**
     处理占位按钮状态
     */
    private func changePlaceholderButton() {
        
        if JFAccountModel.isLogin() {
            if self.videoInfos.count == 0 {
                self.placeholderButton.hidden = false
                self.placeholderButton.selected = true
            } else {
                self.placeholderButton.hidden = true
                self.placeholderButton.selected = true
            }
        } else {
            self.placeholderButton.hidden = false
            self.placeholderButton.selected = false
            self.videoInfos.removeAll()
            self.tableView.reloadData()
        }
        
    }
    
    /**
     点击了占位按钮
     */
    @objc private func didTappedPlaceholderButton(button: UIButton) {
        if isLogin(self) {
            tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - 懒加载
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: SCREEN_BOUNDS, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.rowHeight = 84
        tableView.registerNib(UINib(nibName: "JFCategoryListCell", bundle: nil), forCellReuseIdentifier: self.collectionIdentifier)
        return tableView
    }()
    
    /// 表头部视图
    lazy var headerView: JFProfileHeaderView = {
        let headerView = NSBundle.mainBundle().loadNibNamed("JFProfileHeaderView", owner: nil, options: nil).last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -(SCREEN_HEIGHT * 2 - self.headerHeight), width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
    /// 自定义导航栏
    lazy var navigationBarView: JFProfileNavigationBarView = {
        let view = JFProfileNavigationBarView()
        view.delegate = self
        return view
    }()
    
    /// 没有数据时的占位按钮
    lazy var placeholderButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.hidden = true
        button.setImage(UIImage(named: "weidenglu"), forState: .Normal)
        button.setImage(UIImage(named: "placeholder_button_bg"), forState: .Selected)
        button.addTarget(self, action: #selector(didTappedPlaceholderButton(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
}


// MARK: - UITableViewDelegate/UITableViewDatasource
extension JFProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoInfos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(collectionIdentifier) as! JFCategoryListCell
        cell.videoInfo = videoInfos[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = videoInfos[indexPath.item]
        navigationController?.pushViewController(playerVc, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 滑动删除事件处理
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let alertC = UIAlertController(title: "你确定删除这套课程？", message: "删除课程后，对应的离线下载内容也会跟着清除", preferredStyle: UIAlertControllerStyle.Alert)
        let actionConfirm = UIAlertAction(title: "确定删除", style: UIAlertActionStyle.Cancel) { (action) in
            if editingStyle == .Delete {
                // 删除视频信息
                JFProgressHUD.showWithStatus("正在删除")
                JFNetworkTools.shareNetworkTool.addOrCancelCollection(self.videoInfos[indexPath.row].id, finished: { (success, result, error) in
                    
                    JFProgressHUD.showSuccessWithStatus("操作成功")
                    guard let result = result where result["status"] == "success" else {
                        return
                    }
                    
                    self.videoInfos.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                    if self.videoInfos.count == 0 {
                        self.placeholderButton.hidden = false
                    } else {
                        self.placeholderButton.hidden = true
                    }
                })
            }
        }
        let actionCancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive) { (action) in
            
        }
        alertC.addAction(actionConfirm)
        alertC.addAction(actionCancel)
        presentViewController(alertC, animated: true) { 
            
        }
        
    }
    
    // 修改滑动删除的文字
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    // 根据偏移量修改导航栏
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y + 20
        navigationBarView.backgroundColor = UIColor(white: 1, alpha: offsetY * (1 / 223.5))
        
        // 导航栏item切换
        if offsetY > 157.5 {
            navigationBarView.itemColorChange(false)
        } else {
            navigationBarView.itemColorChange(true)
        }
        
        // 导航栏标题切换
        if offsetY > 223.5 {
            navigationBarView.titleColorChange(false)
        } else {
            navigationBarView.titleColorChange(true)
        }
        
        // 头像缩放动画
        if offsetY > 85.5 {
            headerView.avatarButton.transform = CGAffineTransformMakeScale(1 - 85.5 * (1 / 223.5), 1 - 85.5 * (1 / 223.5))
        } else if offsetY < -20 {
            headerView.avatarButton.transform = CGAffineTransformMakeScale(1 - -20 * (1 / 223.5), 1 - -20 * (1 / 223.5))
        } else {
            headerView.avatarButton.transform = CGAffineTransformMakeScale(1 - offsetY * (1 / 223.5), 1 - offsetY * (1 / 223.5))
        }
        
    }
    
}

// MARK: - JFProfileNavigationBarViewDelegate
extension JFProfileViewController: JFProfileNavigationBarViewDelegate {
    
    /**
     点击了设置
     */
    func didTappedSetting() {
        navigationController?.pushViewController(JFSettingViewController(style: UITableViewStyle.Grouped), animated: true)
    }
}

// MARK: - JFProfileHeaderViewDelegate
extension JFProfileViewController: JFProfileHeaderViewDelegate {
    
    /**
     配置imagePicker
     
     - parameter sourceType:  资源类型
     */
    func setupImagePicker(sourceType: UIImagePickerControllerSourceType) {
        imagePickerC.view.backgroundColor = COLOR_ALL_BG
        imagePickerC.delegate = self
        imagePickerC.sourceType = sourceType
        imagePickerC.allowsEditing = true
        imagePickerC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
    }
    
    /**
     头像按钮点击
     */
    func didTappedAvatarButton(button: UIButton) {
        if isLogin(self) {
            let alertC = UIAlertController()
            let takeAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default, handler: { (action) in
                if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                    JFProgressHUD.showInfoWithStatus("摄像头不可用")
                    return
                }
                self.setupImagePicker(.Camera)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let photoLibraryAction = UIAlertAction(title: "从相册选择照片", style: UIAlertActionStyle.Default, handler: { (action) in
                if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                    JFProgressHUD.showInfoWithStatus("相册不可用")
                    return
                }
                self.setupImagePicker(.PhotoLibrary)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in
                
            })
            alertC.addAction(takeAction)
            alertC.addAction(photoLibraryAction)
            alertC.addAction(cancelAction)
            if iPhoneModel.getCurrentModel() == .iPad {
                let popover = alertC.popoverPresentationController
                popover?.sourceView = button
                popover?.sourceRect = button.bounds
            }
            self.presentViewController(alertC, animated: true, completion: {})
        }
    }
    
    /**
     下载管理
     */
    func didTappedDownloadButton() {
        JFProgressHUD.showInfoWithStatus("暂未开放")
    }
    
    /**
     朋友列表
     */
    func didTappedFriendButton() {
        if isLogin(self) {
            navigationController?.pushViewController(JFFriendViewController(style: UITableViewStyle.Plain), animated: true)
        }
    }
    
    /**
     消息列表
     */
    func didTappedMessageButton() {
        if isLogin(self) {
            navigationController?.pushViewController(JFMessageListViewController(style: UITableViewStyle.Plain), animated: true)
        }
    }
    
    /**
     资料
     */
    func didTappedInfoButton() {
        if isLogin(self) {
            navigationController?.pushViewController(JFInfomationViewController(style: UITableViewStyle.Plain), animated: true)
        }
    }
}


// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newImage = image.resizeImageWithNewSize(CGSize(width: 150, height: 150))
        uploadUserAvatar(newImage)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     上传用户头像
     
     - parameter image: 头像图片
     */
    func uploadUserAvatar(image: UIImage) {
        
        JFAccountModel.uploadUserAvatar(image) { (success) in
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    self.updateData()
                })
            }
        }
    }
}
