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
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
