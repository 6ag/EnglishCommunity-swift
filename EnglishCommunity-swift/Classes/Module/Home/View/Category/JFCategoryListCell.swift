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
                print("videoInfo没有值")
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var joinCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    
}
