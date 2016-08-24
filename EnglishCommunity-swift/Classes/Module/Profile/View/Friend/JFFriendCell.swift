//
//  JFFriendCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/22.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFFriendCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var relationUser: JFRelationUser? {
        didSet {
            guard let relationUser = relationUser else {
                return
            }
            
            avatarImageView.yy_imageURL = NSURL(string: relationUser.relationAvatar!)
            nicknameLabel.text = relationUser.relationNickname!
            sexImageView.image = relationUser.relationSex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            sayLabel.text = relationUser.relationSay ?? "对方很懒，还没有心情哦！"
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(sexImageView)
        contentView.addSubview(sayLabel)
        contentView.addSubview(separatorView)
        
        avatarImageView.snp_makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp_right).offset(MARGIN)
            make.top.equalTo(avatarImageView.snp_top)
        }
        
        sexImageView.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_right).offset(MARGIN * 0.5)
            make.centerY.equalTo(nicknameLabel)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        sayLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.bottom.equalTo(avatarImageView.snp_bottom)
        }
        
        separatorView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
    }

    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = COLOR_ALL_CELL_HIGH
        } else {
            contentView.backgroundColor = COLOR_ALL_CELL_NORMAL
        }
    }
    
    // MARK: - 懒加载
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
    
    /// 性别
    private lazy var sexImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 个性签名
    private lazy var sayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.colorWithHexString("444444")
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    
    /// 分割线
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return view
    }()
}
