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
    func commentCell(_ cell: JFCommentCell, didTappedAvatarButton button: UIButton)
    func commentCell(_ cell: JFCommentCell, didTappedAtUser nickname: String, sequence: Int)
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
            
            if let extendsAuthor = comment.extendsAuthor {
                let contentString = "回复 @\(extendsAuthor.nickname ?? "") : \(comment.content ?? "")"
                contentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(contentString, font: contentLabel.font)
            } else {
                contentLabel.attributedText = JFEmoticon.emoticonStringToEmoticonAttrString(comment.content ?? "", font: contentLabel.font)
            }
            
            avatarButton.setBackgroundImage(urlString: author.avatar, size: CGSize(width: 30, height: 30))
            nicknameLabel.text = author.nickname
            sexImageView.image = author.sex == 0 ? UIImage(named: "girl_dongtai") : UIImage(named: "boy_dongtai")
            publishTimeLabel.text = comment.publishTime?.timeStampToDate().dateToDescription()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = COLOR_ALL_BG
        contentLabel.labelDelegate = self
        
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
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
    
    /**
     计算行高 - 暂时这个cell高度是固定的，所以这个方法不用
     */
    func getRowHeight(_ comment: JFComment) -> CGFloat {
        self.comment = comment
        setNeedsLayout()
        layoutIfNeeded()
        return contentLabel.frame.maxY + 15
    }
    
    @IBAction func didTappedAvatarButton(_ sender: UIButton) {
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
    func labelDidSelectedLinkText(_ label: FFLabel, text: String) {
        
        // 点击了 @昵称
        if text.hasPrefix("@") {
            guard let content = label.text else {
                return
            }
            
            if let sequence = content.checkAtUserNickname()?.index(of: text) {
                let nickname = text.replacingOccurrences(of: "@", with: "")
                delegate?.commentCell(self, didTappedAtUser: nickname, sequence: Int(sequence))
            }
            
        }
        
    }
    
}
