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
            
            avatarImageView.setAvatarImage(urlString: relationUser.relationAvatar, placeholderImage: UIImage(named: "default－portrait"))
            nicknameLabel.text = relationUser.relationNickname
            sexImageView.image = relationUser.relationSex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            sayLabel.text = relationUser.relationSay ?? "对方很懒，还没有心情哦！"
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(sexImageView)
        contentView.addSubview(sayLabel)
        contentView.addSubview(separatorView)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(MARGIN)
            make.top.equalTo(avatarImageView.snp.top)
        }
        
        sexImageView.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp.right).offset(MARGIN * 0.5)
            make.centerY.equalTo(nicknameLabel)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        sayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.bottom.equalTo(avatarImageView.snp.bottom)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
    }

    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
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
        return imageView
    }()
    
    /// 昵称
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    /// 性别
    fileprivate lazy var sexImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 个性签名
    fileprivate lazy var sayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.colorWithHexString("444444")
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// 分割线
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return view
    }()
}
