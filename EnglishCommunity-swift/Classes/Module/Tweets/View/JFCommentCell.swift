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
            
            guard let author = comment.author else {
                return
            }
            
            contentLabel.text = comment.content
            
            if let extendsAuthor = comment.extendsAuthor {
                contentLabel.text = "回复 \(extendsAuthor.nickname!) : \(comment.content!)"
            }
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: author.avatar!), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = author.nickname!
            publishTimeLabel.text = comment.publishTime?.timeStampToDate().dateToDescription()
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
