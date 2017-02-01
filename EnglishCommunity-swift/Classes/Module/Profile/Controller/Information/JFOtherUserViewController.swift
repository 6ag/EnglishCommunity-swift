//
//  JFOtherUserViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/21.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
import YYWebImage

class JFOtherUserViewController: UIViewController {

    /// 用户id
    var userId: Int = 0 {
        didSet {
            loadUserInfo(userId)
        }
    }
    
    /// 用户信息
    var userInfo: JFAccountModel? {
        didSet {
            guard let userInfo = userInfo else {
                return
            }
            
            avatarButton.yy_setBackgroundImage(with: URL(string: userInfo.avatar!), for: UIControlState(), options: YYWebImageOptions.progressive)
            nicknameButton.setTitle(userInfo.nickname!, for: UIControlState())
            sexImageView.image = userInfo.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            followingLabel.text = "关注 \(userInfo.followingCount)"
            followersLabel.text = "粉丝 \(userInfo.followersCount)"
            sayLabel.text = "\"\(userInfo.say ?? "对方很懒，还没有心情哦！")\""
            followButton.setTitle(userInfo.followed == 0 ? "关注" : "取消关注", for: UIControlState())
            if userInfo.id == JFAccountModel.shareAccount()?.id {
                followButton.isHidden = true
            } else {
                followButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "用户中心"
        view.backgroundColor = COLOR_ALL_BG
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        view.addSubview(headerView)
        view.addSubview(nicknameButton)
        view.addSubview(sexImageView)
        view.addSubview(followingLabel)
        view.addSubview(lineView)
        view.addSubview(followersLabel)
        view.addSubview(sayLabel)
        view.addSubview(followButton)
        view.addSubview(avatarButton)
        
        headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(191)
        }
        
        avatarButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(headerView.snp.bottom)
            make.size.equalTo(CGSize(width: 83, height: 83))
        }
        
        nicknameButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-10)
            make.top.equalTo(avatarButton.snp.bottom).offset(15)
        }
        
        sexImageView.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameButton.snp.right).offset(5)
            make.centerY.equalTo(nicknameButton)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        
        followingLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(-40)
            make.top.equalTo(nicknameButton.snp.bottom).offset(15)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.equalTo(followingLabel)
            make.size.equalTo(CGSize(width: 0.5, height: 10))
        }
        
        followersLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(40)
            make.top.equalTo(nicknameButton.snp.bottom).offset(15)
        }
        
        sayLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(followingLabel.snp.bottom).offset(27)
            make.width.equalTo(SCREEN_WIDTH - 100)
        }
        
        followButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(49)
        }
        
    }
    
    /**
     加载用户信息
     
     - parameter userId: 用户id
     */
    fileprivate func loadUserInfo(_ userId: Int) {
        
        JFProgressHUD.show()
        JFAccountModel.getOtherUserInfo(userId) { (userInfo) in
            JFProgressHUD.dismiss()
            guard let userInfo = userInfo else {
                return
            }
            
            self.userInfo = userInfo
        }
    }
    
    /**
     点击了关注按钮
     */
    @objc fileprivate func didTappedFollowButton() {
        
        JFProgressHUD.show()
        JFNetworkTools.shareNetworkTool.addOrCancelFriend(userId, finished: { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                JFProgressHUD.dismiss()
                return
            }
            
            if result["result"]["type"].stringValue == "add" {
                self.followButton.setTitle("取消关注", for: UIControlState())
            } else {
                self.followButton.setTitle("关注", for: UIControlState())
            }
            
            JFAccountModel.getSelfUserInfo({ (success) in
                JFProgressHUD.showInfoWithStatus("操作成功")
            })
        })
    }
    
    /**
     点击了头像
     */
    @objc fileprivate func didTappedAvatarButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            UIView.animate(withDuration: 0.25, animations: { 
                button.transform = CGAffineTransform(scaleX: SCREEN_WIDTH / button.width, y: SCREEN_WIDTH / button.width)
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                button.transform = CGAffineTransform.identity
            })
        }
    }
    
    // MARK: - 懒加载
    /// 头部视图
    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_NAV_BG
        return view
    }()
    
    /// 头像
    fileprivate lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 41.5
        button.layer.borderColor = COLOR_ALL_BG.cgColor
        button.layer.borderWidth = 3
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTappedAvatarButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 昵称
    fileprivate lazy var nicknameButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.colorWithHexString("444444"), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return button
    }()
    
    /// 性别
    fileprivate lazy var sexImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 粉丝
    fileprivate lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("7b9cac")
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    /// 竖线
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorWithHexString("7b9cac")
        return view
    }()
    
    /// 关注
    fileprivate lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.colorWithHexString("7b9cac")
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    /// 个性签名
    fileprivate lazy var sayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.colorWithHexString("444444")
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    /// 关注按钮
    fileprivate lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "bierenziliao_icon_guanzhu"), for: UIControlState())
        button.setTitleColor(UIColor.colorWithHexString("41ca61"), for: UIControlState())
        button.addTarget(self, action: #selector(didTappedFollowButton), for: .touchUpInside)
        button.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
        button.layer.borderWidth = 0.5
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()

}
