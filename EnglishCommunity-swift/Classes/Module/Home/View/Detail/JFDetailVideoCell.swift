//
//  JFDetailVideoCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/6.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFDetailVideoCell: UITableViewCell {

    var model: JFVideo? {
        didSet {
            videoTitleLabel.text = model?.title
        }
    }
    
    @IBOutlet weak var indicatorButton: UIButton!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        videoTitleLabel.textColor = selected ? UIColor.colorWithHexString("41ca61") : UIColor.colorWithHexString("6b6b6b")
        indicatorButton.selected = selected
    }
    
}
