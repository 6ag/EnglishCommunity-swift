//
//  JFGrammarListCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFGrammarListCell: UITableViewCell {

    var grammar: JFGrammar? {
        didSet {
            textLabel?.text = grammar?.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = COLOR_ALL_BG
        } else {
            contentView.backgroundColor = UIColor.whiteColor()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
