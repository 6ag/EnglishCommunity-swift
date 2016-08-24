//
//  JFHomeCellItem.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFHomeCellItem: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var photoImageConstraint: NSLayoutConstraint!
    
    var videoInfo: JFVideoInfo? {
        didSet {
            photoImageView.yy_imageURL = NSURL(string: videoInfo!.cover!)
            titleLabel.text = videoInfo!.title!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = COLOR_ALL_BG
        bgView.layer.cornerRadius = 3
        bgView.layer.masksToBounds = true
        photoImageConstraint.constant = LIST_ITEM_HEIGHT - 40
    }

}
