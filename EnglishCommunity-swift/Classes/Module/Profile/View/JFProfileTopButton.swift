//
//  JFProfileTopButton.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/23.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileTopButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textAlignment = .Center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRect(x: (frame.size.width - 19) * 0.5, y: 20, width: 19, height: 19)
        titleLabel?.frame = CGRect(x: 0, y: 40, width: frame.size.width, height: 20)
    }

}
