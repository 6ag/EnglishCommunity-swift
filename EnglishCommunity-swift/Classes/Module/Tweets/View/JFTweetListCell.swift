//
//  JFTweetListCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFTweetListCellDelegate: NSObjectProtocol {
    func tweetListCell(_ cell: JFTweetListCell, didTappedAvatarButton button: UIButton)
    func tweetListCell(_ cell: JFTweetListCell, didTappedLikeButton button: UIButton)
    func tweetListCell(_ cell: JFTweetListCell, didTappedSuperLink url: String)
    func tweetListCell(_ cell: JFTweetListCell, didTappedAtUser nickname: String, sequence: Int)
}

class JFTweetListCell: UITableViewCell {
    
    // MARK: - 初始化cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let grayColor = UIColor.gray
    
    weak var tweetListCellDelegate: JFTweetListCellDelegate?
    
    /// 动弹模型
    var tweet: JFTweet? {
        didSet {
            guard let tweet = tweet else {
                return
            }
            
            avatarButton.setBackgroundImage(urlString: tweet.author?.avatar, size: CGSize(width: 40, height: 40))
            nicknameLabel.text = tweet.author?.nickname
            contentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(tweet.content ?? "", font: contentLabel.font)
            pictureView.images = tweet.images
            publishTimeLabel.text = tweet.publishTime?.timeStampToDate().dateToDescription()
            appClientLabel.text = tweet.appClient == 0 ? "iOS客户端" : "Android客户端"
            likeButton.setTitle("\(tweet.likeCount)", for: UIControlState())
            likeButton.isSelected = tweet.liked == 1
            commentButton.setTitle("\(tweet.commentCount)", for: UIControlState())
            sexImageView.image = tweet.author!.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            
            let margin: CGFloat = 10
            let width = (SCREEN_WIDTH - MARGIN * 2 - margin * 2) / 3
            
            // 更新配图区域尺寸
            pictureView.snp.updateConstraints { (make) in
                make.size.equalTo(pictureView.calculateViewSize(width, itemHeight: width, margin: margin))
            }
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        selectionStyle = .none
        contentView.backgroundColor = COLOR_ALL_BG
        contentView.addSubview(avatarButton)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(sexImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(publishTimeLabel)
        contentView.addSubview(appClientLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(lineView)
        
        avatarButton.snp.makeConstraints { (make) in
            make.left.top.equalTo(MARGIN)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarButton.snp.right).offset(MARGIN * 0.5)
            make.top.equalTo(avatarButton.snp.top).offset(MARGIN * 0.25)
        }
        
        sexImageView.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp.right).offset(5)
            make.centerY.equalTo(nicknameLabel)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        publishTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(MARGIN * 0.25)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarButton)
            make.top.equalTo(avatarButton.snp.bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH - 2.5 * MARGIN - 40)
        }
        
        pictureView.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(40)
        }
        
        appClientLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel)
            make.top.equalTo(pictureView.snp.bottom).offset(MARGIN * 0.5)
        }
        
        commentButton.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-MARGIN)
            make.centerY.equalTo(appClientLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.right.equalTo(commentButton.snp.left)
            make.centerY.equalTo(appClientLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.right.equalTo(-MARGIN)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
        
        // 离屏渲染
        layer.drawsAsynchronously = true
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    /**
     计算cell行高
     */
    func getRowHeight(_ tweet: JFTweet) -> CGFloat {
        self.tweet = tweet
        layoutIfNeeded()
        return appClientLabel.frame.maxY + 15
    }
    
    // MARK: - 点击事件
    /**
     点击头像按钮
     */
    @objc fileprivate func didTappedAvatarButton(_ button: UIButton) {
        tweetListCellDelegate?.tweetListCell(self, didTappedAvatarButton: button)
    }
    
    /**
     点击赞按钮
     */
    @objc fileprivate func didTappedLikeButton(_ button: UIButton) {
        setupButtonSpringAnimation(button)
        tweetListCellDelegate?.tweetListCell(self, didTappedLikeButton: button)
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
    fileprivate lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTappedAvatarButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 昵称
    fileprivate lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    /// 性别
    fileprivate lazy var sexImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 动弹文字内容
    fileprivate lazy var contentLabel: FFLabel = {
        let label = FFLabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.labelDelegate = self
        return label
    }()
    
    /// 动弹配图
    fileprivate lazy var pictureView = JFTweetPictureView()
    
    /// 动弹发布时间
    fileprivate lazy var publishTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = self.grayColor
        return label
    }()
    
    /// app客户端类型
    fileprivate lazy var appClientLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = self.grayColor
        return label
    }()
    
    /// 动弹赞按钮
    fileprivate lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "star_icon_normal"), for: UIControlState())
        button.setImage(UIImage(named: "star_icon_selected"), for: .highlighted)
        button.setImage(UIImage(named: "dongtai_yizan"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(self.grayColor, for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didTappedLikeButton(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 动弹评论按钮
    fileprivate lazy var commentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "comment_icon"), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(self.grayColor, for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()
    
    /// 分割线
    fileprivate lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return lineView
    }()
    
}

// MARK: - FFLabelDelegate
extension JFTweetListCell: FFLabelDelegate {
    
    /**
     选中高亮的文字后回调
     
     - parameter label: 所在的label
     - parameter text:  被选中的文字
     */
    func labelDidSelectedLinkText(_ label: FFLabel, text: String) {
        
        // 点击了 超链接
        if text.hasPrefix("http") {
            tweetListCellDelegate?.tweetListCell(self, didTappedSuperLink: text)
        }
        
        // 点击了 @昵称
        if text.hasPrefix("@") {
            guard let content = label.text else {
                return
            }
            
            if let sequence = content.checkAtUserNickname()?.index(of: text) {
                let nickname = text.replacingOccurrences(of: "@", with: "")
                tweetListCellDelegate?.tweetListCell(self, didTappedAtUser: nickname, sequence: Int(sequence))
            }
            
        }
        
    }
    
}
