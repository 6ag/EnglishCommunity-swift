//
//  JFTweetsDetailHeaderView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFTweetsDetailHeaderViewDelegate: NSObjectProtocol {
    
    func tweetsDetailHeaderView(headerView: JFTweetsDetailHeaderView, didTappedAvatarButton button: UIButton)
    func tweetsDetailHeaderView(headerView: JFTweetsDetailHeaderView, didTappedLikeButton button: UIButton)
}

class JFTweetsDetailHeaderView: UIView {
    
    // MARK: - 初始化cell
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let grayColor = UIColor.grayColor()
    
    var tweetsDetailHeaderDelegate: JFTweetsDetailHeaderViewDelegate?
    
    /// 动弹模型
    var tweets: JFTweets? {
        didSet {
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: tweets!.author!.avatar!), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = tweets!.author!.nickname!
            contentLabel.text = tweets?.content
            pictureView.images = tweets?.images
            publishTimeLabel.text = tweets?.publishTime?.timeStampToDate().dateToDescription()
            appClientLabel.text = tweets?.appClient == 0 ? "iOS客户端" : "Android客户端"
            likeButton.setTitle("\(tweets!.likeCount)", forState: .Normal)
            commentButton.setTitle("\(tweets!.commentCount)", forState: .Normal)
            
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
            make.centerY.equalTo(avatarButton)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton)
            make.top.equalTo(avatarButton.snp_bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH - 2 * MARGIN)
        }
        
        pictureView.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton)
            make.top.equalTo(contentLabel.snp_bottom).offset(MARGIN * 0.5)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(40)
        }
        
        publishTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarButton)
            make.top.equalTo(pictureView.snp_bottom).offset(MARGIN * 0.5)
        }
        
        appClientLabel.snp_makeConstraints { (make) in
            make.left.equalTo(publishTimeLabel.snp_right).offset(MARGIN * 0.5)
            make.centerY.equalTo(publishTimeLabel)
        }
        
        commentButton.snp_makeConstraints { (make) in
            make.right.equalTo(self.snp_right).offset(-MARGIN)
            make.centerY.equalTo(publishTimeLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        likeButton.snp_makeConstraints { (make) in
            make.right.equalTo(commentButton.snp_left)
            make.centerY.equalTo(publishTimeLabel)
            make.size.equalTo(CGSize(width: 50, height: 20))
        }
        
        lineView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
        
    }
    
    /**
     计算cell行高
     */
    func getRowHeight(tweets: JFTweets) -> CGFloat {
        self.tweets = tweets
        layoutIfNeeded()
        return CGRectGetMaxY(publishTimeLabel.frame) + 15
    }
    
    // MARK: - 点击事件
    /**
     点击头像按钮
     */
    @objc private func didTappedAvatarButton(button: UIButton) {
        tweetsDetailHeaderDelegate?.tweetsDetailHeaderView(self, didTappedAvatarButton: button)
    }
    
    /**
     点击赞按钮
     */
    @objc private func didTappedLikeButton(button: UIButton) {
        tweetsDetailHeaderDelegate?.tweetsDetailHeaderView(self, didTappedLikeButton: button)
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
    
    /// 动弹文字内容
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    
    /// 动弹配图
    private lazy var pictureView = JFTweetsPictureView()
    
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
        button.setImage(UIImage(named: "star_icon_selected"), forState: .Selected)
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
        lineView.backgroundColor = RGB(0.3, g: 0.3, b: 0.3, alpha: 0.2)
        return lineView
    }()
    
}
