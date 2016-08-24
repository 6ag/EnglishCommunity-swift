//
//  JFCommentCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

protocol JFCommentCellDelegate: NSObjectProtocol {
    func commentCell(cell: JFCommentCell, didTappedAvatarButton button: UIButton)
    func commentCell(cell: JFCommentCell, didTappedAtUser nickname: String, sequence: Int)
}

class JFCommentCell: UITableViewCell {
    
    weak var delegate: JFCommentCellDelegate?
    
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
                let contentString = "回复 @\(extendsAuthor.nickname!) : \(comment.content!)"
                contentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(contentString, font: contentLabel.font)
            } else {
                contentLabel.attributedText = contentString
            }
            
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: author.avatar!), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = author.nickname!
            sexImageView.image = author.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            publishTimeLabel.text = comment.publishTime?.timeStampToDate().dateToDescription()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = COLOR_ALL_BG
        contentLabel.labelDelegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - MARGIN * 2
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
    
    /**
     计算行高 - 暂时这个cell高度是固定的，所以这个方法不用
     */
    func getRowHeight(comment: JFComment) -> CGFloat {
        self.comment = comment
        setNeedsLayout()
        layoutIfNeeded()
        return CGRectGetMaxY(contentLabel.frame) + 15
    }
    
    @IBAction func didTappedAvatarButton(sender: UIButton) {
        delegate?.commentCell(self, didTappedAvatarButton: sender)
    }
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var contentLabel: FFLabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
}

// MARK: - FFLabelDelegate
extension JFCommentCell: FFLabelDelegate {
    
    /**
     选中高亮的文字后回调
     
     - parameter label: 所在的label
     - parameter text:  被选中的文字
     */
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        
        // 点击了 @昵称
        if text.hasPrefix("@") {
            guard let content = label.text else {
                return
            }
            
            if let sequence = content.checkAtUserNickname()?.indexOf(text) {
                let nickname = text.stringByReplacingOccurrencesOfString("@", withString: "")
                delegate?.commentCell(self, didTappedAtUser: nickname, sequence: Int(sequence))
            }
            
        }
        
    }
    
}
