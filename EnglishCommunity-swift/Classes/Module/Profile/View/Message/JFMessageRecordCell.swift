//
//  JFMessageRecordCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/23.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

protocol JFMessageRecordCellDelegate: NSObjectProtocol {
    func messageRecordCell(cell: JFMessageRecordCell, didTappedAvatarButton button: UIButton)
}

class JFMessageRecordCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: JFMessageRecordCellDelegate?
    
    /// 消息记录
    var messageRecord: JFMessageRecord? {
        didSet {
            guard let messageRecord = messageRecord else {
                return
            }
            
            sourceContentLabel.hidden = false
            avatarButton.yy_setImageWithURL(NSURL(string: messageRecord.byUser!.avatar!), forState: .Normal, options: YYWebImageOptions(rawValue: 0))
            nicknameLabel.text = messageRecord.byUser!.nickname!
            sexImageView.image = messageRecord.byUser!.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            
            if messageRecord.messageType == "comment" {
                if messageRecord.type == "tweet" {
                    let prefix = NSMutableAttributedString(string: "回复了动态: \n")
                    prefix.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : contentLabel.font], range: NSRange(location: 0, length: "回复了动态: \n".characters.count))
                    prefix.appendAttributedString(JFEmoticon.emoticonStringToEmoticonAttrString(messageRecord.content!, font: contentLabel.font))
                    contentLabel.attributedText = prefix
                    sourceContentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(messageRecord.sourceContent!, font: sourceContentLabel.font)
                } else {
                    let prefix = NSMutableAttributedString(string: "回复了你的评论: \n")
                    prefix.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : contentLabel.font], range: NSRange(location: 0, length: "回复了评论: \n".characters.count))
                    prefix.appendAttributedString(JFEmoticon.emoticonStringToEmoticonAttrString(messageRecord.content!, font: contentLabel.font))
                    contentLabel.attributedText = prefix
                    sourceContentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(messageRecord.sourceContent!, font: sourceContentLabel.font)
                }
            } else {
                let prefix = NSMutableAttributedString(string: "在动态中提到了你: \n")
                prefix.addAttributes([NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : contentLabel.font], range: NSRange(location: 0, length: "在动态中提到了你: \n".characters.count))
                prefix.appendAttributedString(JFEmoticon.emoticonStringToEmoticonAttrString(messageRecord.content!, font: contentLabel.font))
                contentLabel.attributedText = prefix
                sourceContentLabel.hidden = true
            }
            
            publishTimeLabel.text = messageRecord.publishTime!.timeStampToDate().dateToDescription()
            
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        selectionStyle = .None
        contentView.addSubview(avatarButton)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(sexImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(sourceContentLabel)
        contentView.addSubview(publishTimeLabel)
        contentView.addSubview(lineView)
        
        avatarButton.snp_makeConstraints { (make) in
            make.left.top.equalTo(5)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton.snp_right).offset(5)
            make.top.equalTo(avatarButton.snp_top)
        }
        
        sexImageView.snp_makeConstraints { (make) in
            make.centerY.equalTo(nicknameLabel)
            make.left.equalTo(nicknameLabel.snp_right).offset(5)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        publishTimeLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(nicknameLabel)
            make.right.equalTo(-5)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_left)
            make.top.equalTo(nicknameLabel.snp_bottom).offset(5)
            make.width.equalTo(SCREEN_WIDTH - 60)
        }
        
        sourceContentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_left)
            make.top.equalTo(contentLabel.snp_bottom).offset(5)
            make.width.equalTo(SCREEN_WIDTH - 60)
        }
        
        lineView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(sourceContentLabel.snp_bottom).offset(10)
            make.height.equalTo(0.5)
        }
        
    }
    
    /**
     计算cell行高
     */
    func getRowHeight(messageRecord: JFMessageRecord) -> CGFloat {
        self.messageRecord = messageRecord
        layoutIfNeeded()
        return CGRectGetMaxY(lineView.frame)
    }
    
    /**
     点击头像按钮
     */
    @objc private func didTappedAvatarButton(button: UIButton) {
        delegate?.messageRecordCell(self, didTappedAvatarButton: button)
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
    private lazy var avatarButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTappedAvatarButton(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    /// 昵称
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(16)
        return label
    }()
    
    /// 性别
    private lazy var sexImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 回复内容
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    
    /// 来源内容
    private lazy var sourceContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        return label
    }()
    
    /// 发布时间
    private lazy var publishTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.grayColor()
        return label
    }()
    
    /// 分割线
    private lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return lineView
    }()
}
