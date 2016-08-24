//
//  JFVideoDownloadCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFVideoDownloadCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 视频模型
    var video: JFVideo? {
        didSet {
            guard let video = video else {
                return
            }
            
            selectorButton.selected = video.selected
            videoTitleLabel.text = video.title ?? ""
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        contentView.addSubview(selectorButton)
        contentView.addSubview(videoTitleLabel)
        
        selectorButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.left.equalTo(MARGIN)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        videoTitleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(selectorButton)
            make.left.equalTo(selectorButton.snp_right).offset(MARGIN * 0.5)
        }
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
    
    // MARK: - 懒加载
    /// 选择图标
    lazy var selectorButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "publish_select_normal"), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "publish_select_selected"), forState: .Selected)
        return button
    }()
    
    lazy var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.colorWithHexString("6b6b6b")
        return label
    }()
    
}
