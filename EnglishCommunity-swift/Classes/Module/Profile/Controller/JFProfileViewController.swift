//
//  JFProfileViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 15/12/20.
//  Copyright © 2015年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFProfileViewController: UITableViewController {
    
    let imagePickerC = UIImagePickerController()
    let headerHeight = SCREEN_HEIGHT * 0.4
    let collectionIdentifier = "collectionIdentifier"
    var page: Int = 0
    var videoInfos = [JFVideoInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 这个是用来占位的
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: headerHeight))
        tableView.showsVerticalScrollIndicator = false
        tableView.addSubview(headerView)
        tableView.separatorStyle = .None
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.rowHeight = 84
        tableView.registerNib(UINib(nibName: "JFCategoryListCell", bundle: nil), forCellReuseIdentifier: collectionIdentifier)
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        updateHeaderData()
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
    }
    
    /**
     更新头部数据
     */
    private func updateHeaderData() {
        if JFAccountModel.isLogin() {
            headerView.avatarButton.yy_setBackgroundImageWithURL(NSURL(string: JFAccountModel.shareAccount()!.avatar!), forState: UIControlState.Normal, options: YYWebImageOptions.AllowBackgroundTask)
            headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname!
        } else {
            headerView.avatarButton.setBackgroundImage(UIImage(named: "default－portrait"), forState: UIControlState.Normal)
            headerView.nameLabel.text = "登录账号"
        }
    }
    
    // MARK: - 懒加载
    /// 表头部视图
    lazy var headerView: JFProfileHeaderView = {
        let headerView = NSBundle.mainBundle().loadNibNamed("JFProfileHeaderView", owner: nil, options: nil).last as! JFProfileHeaderView
        headerView.delegate = self
        headerView.frame = CGRect(x: 0, y: -(SCREEN_HEIGHT * 2 - self.headerHeight + 20), width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 2)
        return headerView
    }()
    
}

// MARK: - UITableViewDelegate/UITableViewDatasource
extension JFProfileViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(collectionIdentifier) as! JFCategoryListCell
        cell.videoInfo = videoInfos[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = videoInfos[indexPath.item]
        navigationController?.pushViewController(playerVc, animated: true)
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
    func didTappedAvatarButton() {
        
        if isLogin(self) {
            let alertC = UIAlertController()
            let takeAction = UIAlertAction(title: "拍照上传", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.Camera)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let photoLibraryAction = UIAlertAction(title: "图库选择", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.PhotoLibrary)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let albumAction = UIAlertAction(title: "相册选择", style: UIAlertActionStyle.Default, handler: { (action) in
                self.setupImagePicker(.SavedPhotosAlbum)
                self.presentViewController(self.imagePickerC, animated: true, completion: {})
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) in
                
            })
            alertC.addAction(takeAction)
            alertC.addAction(photoLibraryAction)
            alertC.addAction(albumAction)
            alertC.addAction(cancelAction)
            self.presentViewController(alertC, animated: true, completion: {})
        }
    }
    
    /**
     朋友列表
     */
    func didTappedFriendButton() {
        if isLogin(self) {
            navigationController?.pushViewController(JFCollectionTableViewController(style: UITableViewStyle.Plain), animated: true)
        }
    }
    
    /**
     消息列表
     */
    func didTappedMessageButton() {
        if isLogin(self) {
           navigationController?.pushViewController(JFCommentListTableViewController(style: UITableViewStyle.Plain), animated: true)
        }
    }
    
    /**
     资料
     */
    func didTappedInfoButton() {
        if isLogin(self) {
            navigationController?.pushViewController(JFEditProfileViewController(style: UITableViewStyle.Grouped), animated: true)
        }
    }
}


// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let newImage = image.resizeImageWithNewSize(CGSize(width: 108, height: 108))
        uploadUserAvatar(newImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     上传用户头像
     
     - parameter image: 头像图片
     */
    func uploadUserAvatar(image: UIImage) {
        
//        let imagePath = saveImageAndGetURL(image, imageName: "avatar.png")
        
//        let parameters: [String : AnyObject] = [
//            "username" : JFAccountModel.shareAccount()!.username!,
//            "userid" : "\(JFAccountModel.shareAccount()!.id)",
//            "token" : JFAccountModel.shareAccount()!.token!,
//            "action" : "UploadAvatar",
//            ]
        
//        JFProgressHUD.showWithStatus("正在上传")
//        JFNetworkTool.shareNetworkTool.uploadUserAvatar("\(MODIFY_ACCOUNT_INFO)", imagePath: imagePath, parameters: parameters) { (success, result, error) in
//            print(result)
//            if success {
//                JFProgressHUD.showInfoWithStatus("上传成功")
//                
//                // 更新用户信息并刷新tableView
//                JFAccountModel.checkUserInfo({
//                    self.updateHeaderData()
//                })
//            } else {
//                JFProgressHUD.showInfoWithStatus("上传失败")
//            }
//        }
    }
}
