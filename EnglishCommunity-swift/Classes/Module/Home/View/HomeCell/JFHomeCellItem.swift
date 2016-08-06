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
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var videoInfo: JFVideoInfo? {
        didSet {
            photoImageView.yy_setImageWithURL(NSURL(string: "\(BASE_URL)\(videoInfo!.photo!)"), options: YYWebImageOptions.AllowBackgroundTask)
            teacherLabel.text = videoInfo!.teacher!
            viewLabel.text = "\(videoInfo!.view)"
            titleLabel.text = videoInfo!.title!
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        
    }

}
