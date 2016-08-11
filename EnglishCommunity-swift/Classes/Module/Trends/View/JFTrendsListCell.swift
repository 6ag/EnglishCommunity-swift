//
//  JFTrendsListCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFTrendsListCell: UITableViewCell {

    var trends: JFTrends? {
        didSet {
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: "\(BASE_URL)\(trends!.user_avatar!)"), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = trends?.user_nickname
            contentLabel.text = trends?.content
            publishTimeLabel.text = trends?.publishTime
            favoriteButton.setTitle("\(trends!.favorite_count)", forState: .Normal)
            commentButton.setTitle("\(trends!.comment_count)", forState: .Normal)
            
            if let photoUrl = trends?.small_photo {
                photoImageView.image = YYImageCache.sharedCache().getImageForKey("\(BASE_URL)\(photoUrl)")
                
                if let image = photoImageView.image {
                    // 有缓存的情况下根据缓存约束宽高
                    var size = CGSizeZero
                    if image.size.height > 100 {
                        size = photoImageView.image!.equalScaleWithWHeight(100)
                    } else if image.size.width > 150 {
                        size = photoImageView.image!.equalScaleWithWidth(150)
                    }
                    
                    photoHeightContraints.constant = size.height
                    photoWidthContraints.constant = size.width
                } else {
                    // 没有缓存、固定宽高
                    photoImageView.yy_setImageWithURL(NSURL(string: "\(BASE_URL)\(photoUrl)"), options: YYWebImageOptions.AllowBackgroundTask)
                    photoHeightContraints.constant = 100
                    photoWidthContraints.constant = 150
                }
            } else {
                photoHeightContraints.constant = 0
                photoWidthContraints.constant = 0
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 76
    }
    
    /**
     计算行高 - 暂时这个cell高度是固定的，所以这个方法不用
     */
    func getRowHeight(trends: JFTrends) -> CGFloat {
        self.trends = trends
        setNeedsLayout()
        layoutIfNeeded()
        return CGRectGetMaxY(publishTimeLabel.frame) + 15
    }
    
    @IBOutlet weak var photoWidthContraints: NSLayoutConstraint!
    @IBOutlet weak var photoHeightContraints: NSLayoutConstraint!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    /**
     点击了动弹列表作者头像
     */
    @IBAction func didTappedTrendsAvatarButton(sender: UIButton) {
        print("头像")
    }
}
