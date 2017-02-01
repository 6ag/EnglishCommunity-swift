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
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var joinCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    var videoInfo: JFVideoInfo? {
        didSet {
            guard let videoInfo = videoInfo else {
                return
            }
            coverImageView.setImage(urlString: videoInfo.cover, placeholderImage: nil)
            titleLabel.text = videoInfo.title
            teacherLabel.text = videoInfo.teacherName
            joinCountLabel.text = "\(videoInfo.view) 人学过"
            videoCountLabel.text = "共\(videoInfo.videoCount)节"
        }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
    }
    
}
