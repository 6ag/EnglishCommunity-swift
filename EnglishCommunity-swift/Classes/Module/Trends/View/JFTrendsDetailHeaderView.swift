//
//  JFTrendsDetailView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/11.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFTrendsDetailHeaderView: UIView {

    var trends: JFTrends? {
        didSet {
            avatarButton.yy_setBackgroundImageWithURL(NSURL(string: "\(BASE_URL)\(trends!.user_avatar!)"), forState: .Normal, options: YYWebImageOptions.AllowBackgroundTask)
            nicknameLabel.text = trends?.user_nickname
            contentLabel.text = trends?.content
            publishTimeLabel.text = trends?.publishTime
            favoriteButton.setTitle("\(trends!.favorite_count)", forState: .Normal)
            commentButton.setTitle("\(trends!.comment_count)", forState: .Normal)
            
            if let photoUrl = trends?.photo {
                print(photoUrl)
                photoImageView.image = YYImageCache.sharedCache().getImageForKey("\(BASE_URL)\(photoUrl)")
                
                if let image = photoImageView.image {
                    // 有缓存的情况下根据缓存约束宽高
                    var size = CGSizeZero
                    if image.size.width > SCREEN_WIDTH - MARGIN * 2 {
                        size = photoImageView.image!.equalScaleWithWidth(SCREEN_WIDTH - MARGIN * 2)
                    } else {
                        size = image.size
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
    
    @IBOutlet weak var photoWidthContraints: NSLayoutConstraint!
    @IBOutlet weak var photoHeightContraints: NSLayoutConstraint!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - MARGIN * 2
    }
    
    /**
     计算高度
     */
    func getRowHeight(trends: JFTrends) -> CGFloat {
        self.trends = trends
        setNeedsLayout()
        layoutIfNeeded()
        return CGRectGetMaxY(publishTimeLabel.frame) + 15
    }
}
