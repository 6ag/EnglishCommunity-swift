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
            textLabel?.text = model?.title
        }
    }
    
    @IBOutlet weak var indicator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicator.backgroundColor = UIColor(red:0.89, green:0.18, blue:0.09, alpha:1.00)
        backgroundColor = RGB(244, g: 244, b: 244, alpha: 1)
        backgroundView = UIView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.y = 2
        textLabel?.height = contentView.height - 4
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        textLabel?.textColor = selected ? UIColor(red:0.89, green:0.18, blue:0.09, alpha:1.00) : UIColor.grayColor()
        indicator.hidden = !selected
    }
    
}
