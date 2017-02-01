//
//  JFInfomationViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/26.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import YYWebImage

class JFInfomationViewController: JFBaseTableViewController {
    
    let modifyInfoIdenfitier = "modifyInfoIdenfitier"
    
    let imagePickerC = UIImagePickerController()
    
    /// 头部高度
    let headerHeight = SCREEN_HEIGHT * 0.3
    
    let left: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "个人资料"
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: headerHeight - 44))
        placeholderView.isUserInteractionEnabled = false
        tableView.tableHeaderView = placeholderView
        tableView.addSubview(headerView)
        updateHeaderData()
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem("保存", target: self, action: #selector(didTappedSaveButton))
        
        let group1CellModel1 = JFProfileCellModel(title: "昵称:")
        let group1CellModel2 = JFProfileCellModel(title: "性别:")
        let group1CellModel3 = JFProfileCellModel(title: "签名:")
        let group1 = JFProfileCellGroupModel(cells: [group1CellModel1, group1CellModel2, group1CellModel3])
        groupModels = [group1]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     点击了保存
     */
    func didTappedSaveButton() {
        
        // 更新内存中的数据
        JFAccountModel.shareAccount()?.nickname = nicknameField.text
        JFAccountModel.shareAccount()?.sex = sexField.text == "女" ? 0 : 1
        JFAccountModel.shareAccount()?.say = sayField.text
        
        JFProgressHUD.showWithStatus("更新资料")
        JFAccountModel.updateUserInfo(JFAccountModel.shareAccount()?.nickname ?? "", sex: JFAccountModel.shareAccount()?.sex ?? 0, say: JFAccountModel.shareAccount()?.say ?? "") { (success) in
            JFProgressHUD.showSuccessWithStatus("更新成功")
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    if success {
                        self.updateHeaderData()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
        }
    }
    
    /**
     更新头部数据
     */
    fileprivate func updateHeaderData() {
        headerView.avatarButton.yy_setBackgroundImage(with: URL(string: JFAccountModel.shareAccount()!.avatar!), for: UIControlState(), options: YYWebImageOptions(rawValue: 0))
        headerView.nameLabel.text = JFAccountModel.shareAccount()!.nickname!
    }
    
    /**
     配置文本框
     
     - parameter placeholder: 占位符
     
     - returns: 返回文本框
     */
    fileprivate func setupTextField(_ placeholder: String) -> UITextField {
        let field = UITextField(frame: CGRect(x: self.left, y: 0, width: SCREEN_WIDTH - 100, height: 44))
        field.font = UIFont.systemFont(ofSize: 14)
        field.textColor = UIColor.colorWithHexString("7b9cac")
        field.placeholder = placeholder
        field.clearButtonMode = .whileEditing
        return field
    }
    
    // MARK: - 懒加载
    /// 头部区域
    lazy var headerView: JFInfoHeaderView = {
        let view = Bundle.main.loadNibNamed("JFInfoHeaderView", owner: nil, options: nil)?.last as! JFInfoHeaderView
        view.delegate = self
        view.frame = CGRect(x: 0, y: -(SCREEN_HEIGHT * 2 - self.headerHeight), width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 2)
        return view
    }()
    
    /// 昵称
    fileprivate lazy var nicknameField: UITextField = {
        return self.setupTextField("昵称")
    }()
    
    /// 性别
    fileprivate lazy var sexField: UITextField = {
        return self.setupTextField("性别")
    }()
    
    /// 签名
    fileprivate lazy var sayField: UITextField = {
        return self.setupTextField("个性签名")
    }()
    
}

// MARK: - tableView数据源、代理
extension JFInfomationViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0: // 昵称
            cell.contentView.addSubview(nicknameField)
            nicknameField.text = JFAccountModel.shareAccount()?.nickname
            return cell
        case 1: // 性别
            cell.contentView.addSubview(sexField)
            sexField.text = JFAccountModel.shareAccount()?.sex == 0 ? "女" : "男"
            sexField.isUserInteractionEnabled = false
            return cell
        case 2: // 签名
            cell.contentView.addSubview(sayField)
            sayField.text = JFAccountModel.shareAccount()?.say
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            let alertC = UIAlertController()
            let manAction = UIAlertAction(title: "男", style: UIAlertActionStyle.default, handler: { (action) in
                JFAccountModel.shareAccount()?.sex = 1
                self.tableView.reloadData()
            })
            let womanAction = UIAlertAction(title: "女", style: UIAlertActionStyle.cancel, handler: { (action) in
                JFAccountModel.shareAccount()?.sex = 0
                self.tableView.reloadData()
            })
            alertC.addAction(manAction)
            alertC.addAction(womanAction)
            self.present(alertC, animated: true, completion: {})
        }
    }
    
}

// MARK: - JFInfoHeaderViewDelegate
extension JFInfomationViewController: JFInfoHeaderViewDelegate {
    
    /**
     配置imagePicker
     
     - parameter sourceType:  资源类型
     */
    func setupImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        imagePickerC.view.backgroundColor = COLOR_ALL_BG
        imagePickerC.delegate = self
        imagePickerC.sourceType = sourceType
        imagePickerC.allowsEditing = true
        imagePickerC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
    }
    
    /**
     头像按钮点击
     */
    func didTappedAvatarButton() {
        let alertC = UIAlertController()
        let takeAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.default, handler: { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                JFProgressHUD.showInfoWithStatus("摄像头不可用")
                return
            }
            self.setupImagePicker(.camera)
            self.present(self.imagePickerC, animated: true, completion: {})
        })
        let photoLibraryAction = UIAlertAction(title: "从相册选择照片", style: UIAlertActionStyle.default, handler: { (action) in
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                JFProgressHUD.showInfoWithStatus("相册不可用")
                return
            }
            self.setupImagePicker(.photoLibrary)
            self.present(self.imagePickerC, animated: true, completion: {})
        })
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        })
        alertC.addAction(takeAction)
        alertC.addAction(photoLibraryAction)
        alertC.addAction(cancelAction)
        self.present(alertC, animated: true, completion: {})
    }
    
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension JFInfomationViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newImage = image.resizeImageWithNewSize(CGSize(width: 150, height: 150))
        uploadUserAvatar(newImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     上传用户头像
     
     - parameter image: 头像图片
     */
    func uploadUserAvatar(_ image: UIImage) {
        
        JFAccountModel.uploadUserAvatar(image) { (success) in
            if success {
                JFAccountModel.getSelfUserInfo({ (success) in
                    if success {
                        self.updateHeaderData()
                    }
                })
            }
        }
    }
}
