//
//  JFCategoriesCellItem.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFCategoriesCellItem: UICollectionViewCell {
    
    var category: JFVideoCategory? {
        didSet {
            titleLabel.text = category!.name!
            iconView.image = UIImage(named: category!.alias!)
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconWidthConstraint.constant = SCREEN_WIDTH * 0.1
        iconHeightConstraint.constant = SCREEN_WIDTH * 0.1
    }

}
