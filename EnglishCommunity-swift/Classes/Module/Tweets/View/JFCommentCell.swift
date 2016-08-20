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
            
            let contentString = JFEmoticon.emoticonStringToEmoticonAttrString(comment.content!, font: contentLabel.font)
            
            if let extendsAuthor = comment.extendsAuthor {
                contentLabel.text = "回复 \(extendsAuthor.nickname!) : \(contentString)"
            } else {
                contentLabel.attributedText = contentString
            }
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: author.avatar!), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = author.nickname!
            publishTimeLabel.text = comment.publishTime?.timeStampToDate().dateToDescription()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = COLOR_ALL_BG
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 76
    }
    
    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)
        } else {
            contentView.backgroundColor = UIColor.whiteColor()
        }
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
