//
//  JFCategoryListCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/18.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFCategoryListCell: UITableViewCell {

    var videoInfo: JFVideoInfo? {
        didSet {
            guard let videoInfo = videoInfo else {
                return
            }
            
            coverImageView.yy_imageURL = NSURL(string: videoInfo.cover!)
            titleLabel.text = videoInfo.title!
            teacherLabel.text = videoInfo.teacherName!
            joinCountLabel.text = "\(videoInfo.view) 人学过"
            videoCountLabel.text = "共\(videoInfo.videoCount)节"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.layer.cornerRadius = 3
        coverImageView.layer.masksToBounds = true
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
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var joinCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
}
