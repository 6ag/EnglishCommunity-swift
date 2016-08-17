//
//  JFSelectFriendCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/16.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFSelectFriendCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var relationUser: JFRelationUser? {
        didSet {
            avatarImageView.yy_setImageWithURL(NSURL(string: relationUser!.relationAvatar!), placeholder: nil)
            nicknameLabel.text = relationUser!.relationNickname!
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        contentView.addSubview(selectorButton)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(separatorView)
        
        selectorButton.snp_makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        avatarImageView.snp_makeConstraints { (make) in
            make.left.equalTo(selectorButton.snp_right).offset(10)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp_right).offset(10)
            make.centerY.equalTo(contentView)
        }
        
        separatorView.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_left)
            make.bottom.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.masksToBounds = true
    }
    
    /// 选择图标
    lazy var selectorButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "publish_select_normal"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "publish_select_selected"), forState: .Selected)
        return button
    }()
    
    /// 头像
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// 昵称
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(16)
        return label
    }()
    
    /// 分割线
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = RGB(0.9, g: 0.9, b: 0.9, alpha: 0.3)
        return view
    }()
    
}
