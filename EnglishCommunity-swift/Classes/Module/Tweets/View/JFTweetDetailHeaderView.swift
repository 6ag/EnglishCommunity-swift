//
//  JFTweetDetailHeaderView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFTweetDetailHeaderViewDelegate: NSObjectProtocol {
    
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedAvatarButton button: UIButton)
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedLikeButton button: UIButton)
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedSuperLink url: String)
    func tweetDetailHeaderView(headerView: JFTweetDetailHeaderView, didTappedAtUser nickname: String, sequence: Int)
}

class JFTweetDetailHeaderView: UIView {
    
    // MARK: - 初始化cell
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let grayColor = UIColor.grayColor()
    
    weak var tweetDetailHeaderDelegate: JFTweetDetailHeaderViewDelegate?
    
    /// 动弹模型
    var tweet: JFTweet? {
        didSet {
            guard let tweet = tweet else {
                return
            }
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: tweet.author!.avatar!), forState: .Normal, options: YYWebImageOptions(rawValue: 0))
            nicknameLabel.text = tweet.author!.nickname!
            contentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(tweet.content!, font: contentLabel.font)
            pictureView.images = tweet.images
            publishTimeLabel.text = tweet.publishTime?.timeStampToDate().dateToDescription()
            appClientLabel.text = tweet.appClient == 0 ? "iOS客户端" : "Android客户端"
            likeButton.setTitle("\(tweet.likeCount)", forState: .Normal)
            likeButton.selected = tweet.liked == 1
            commentButton.setTitle("\(tweet.commentCount)", forState: .Normal)
            sexImageView.image = tweet.author!.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            
            let margin: CGFloat = 10
            let width = (SCREEN_WIDTH - MARGIN * 2 - margin * 2) / 3
            
            // 更新配图区域尺寸
            pictureView.snp_updateConstraints { (make) in
                make.size.equalTo(pictureView.calculateViewSize(width, itemHeight: width, margin: margin))
            }
            
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        addSubview(avatarButton)
        addSubview(nicknameLabel)
        addSubview(sexImageView)
        addSubview(contentLabel)
        addSubview(pictureView)
        addSubview(publishTimeLabel)
        addSubview(appClientLabel)
        addSubview(commentButton)
        addSubview(likeButton)
        addSubview(lineView)
        
        avatarButton.snp_makeConstraints { (make) in
            make.left.top.equalTo(MARGIN)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        nicknameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton.snp_right).offset(MARGIN * 0.5)
            make.top.equalTo(avatarButton.snp_top).offset(MARGIN * 0.25)
        }
        
        sexImageView.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel.snp_right).offset(5)
            make.centerY.equalTo(nicknameLabel)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        publishTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(nicknameLabel.snp_bottom).offset(MARGIN * 0.25)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton)
            make.top.equalTo(avatarButton.snp_bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH - 2.5 * MARGIN - 40)
        }
        
        pictureView.snp_makeConstraints { (make) in
            make.left.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp_bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(40)
        }
        
        appClientLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentLabel)
            make.top.equalTo(pictureView.snp_bottom).offset(MARGIN * 0.5)
        }
        
        commentButton.snp_makeConstraints { (make) in
            make.right.equalTo(self.snp_right).offset(-MARGIN)
            make.centerY.equalTo(appClientLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        likeButton.snp_makeConstraints { (make) in
            make.right.equalTo(commentButton.snp_left)
            make.centerY.equalTo(appClientLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        lineView.snp_makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.right.equalTo(-MARGIN)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
        
    }
    
    /**
     计算cell行高 - 和列表公用一个高度
     */
    func getRowHeight(tweet: JFTweet) -> CGFloat {
        self.tweet = tweet
        layoutIfNeeded()
        return CGRectGetMaxY(appClientLabel.frame) + 15
    }
    
    // MARK: - 点击事件
    /**
     点击头像按钮
     */
    @objc private func didTappedAvatarButton(button: UIButton) {
        tweetDetailHeaderDelegate?.tweetDetailHeaderView(self, didTappedAvatarButton: button)
    }
    
    /**
     点击赞按钮
     */
    @objc private func didTappedLikeButton(button: UIButton) {
        tweetDetailHeaderDelegate?.tweetDetailHeaderView(self, didTappedLikeButton: button)
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
    
    /// 动弹文字内容
    private lazy var contentLabel: FFLabel = {
        let label = FFLabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.labelDelegate = self
        return label
    }()
    
    /// 动弹配图
    private lazy var pictureView = JFTweetPictureView()
    
    /// 动弹发布时间
    private lazy var publishTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = self.grayColor
        return label
    }()
    
    /// app客户端类型
    private lazy var appClientLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = self.grayColor
        return label
    }()
    
    /// 动弹赞按钮
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "star_icon_normal"), forState: .Normal)
        button.setImage(UIImage(named: "star_icon_selected"), forState: .Highlighted)
        button.setImage(UIImage(named: "dongtai_yizan"), forState: .Selected)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(self.grayColor, forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didTappedLikeButton(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    /// 动弹评论按钮
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "comment_icon"), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
        button.setTitleColor(self.grayColor, forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return button
    }()
    
    /// 分割线
    private lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return lineView
    }()
    
}

// MARK: - FFLabelDelegate
extension JFTweetDetailHeaderView: FFLabelDelegate {
    
    /**
     选中高亮的文字后回调
     
     - parameter label: 所在的label
     - parameter text:  被选中的文字
     */
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        // 点击了 超链接
        if text.hasPrefix("http") {
            tweetDetailHeaderDelegate?.tweetDetailHeaderView(self, didTappedSuperLink: text)
        }
        
        // 点击了 @昵称
        if text.hasPrefix("@") {
            guard let content = label.text else {
                return
            }
            
            if let sequence = content.checkAtUserNickname()?.indexOf(text) {
                let nickname = text.stringByReplacingOccurrencesOfString("@", withString: "")
                tweetDetailHeaderDelegate?.tweetDetailHeaderView(self, didTappedAtUser: nickname, sequence: Int(sequence))
            }
            
        }
    }
}
