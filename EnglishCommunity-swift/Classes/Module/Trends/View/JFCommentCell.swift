//
//  JFCommentCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFCommentCell: UITableViewCell {
    
    /// 评论模型
    var comment: JFComment? {
        didSet {
            guard let comment = comment else {
                return
            }
            
            // 是回复评论
            if comment.pid != 0 {
                contentLabel.text = "回复 \(comment.puser_nickname!) : \(comment.content!)"
            } else {
                contentLabel.text = comment.content
            }
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: "\(BASE_URL)\(comment.user_avatar!)"), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = comment.user_nickname
            publishTimeLabel.text = comment.publishTime
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 76
    }
    
    /**
     计算行高 - 暂时这个cell高度是固定的，所以这个方法不用
     */
    func getRowHeight(comment: JFComment) -> CGFloat {
        self.comment = comment
        setNeedsLayout()
        layoutIfNeeded()
        return CGRectGetMaxY(contentLabel.frame) + 15
    }
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
}
