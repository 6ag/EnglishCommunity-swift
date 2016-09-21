//
//  JFPlayerClearityChooseButton.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/3.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFPlayerClearityChooseButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    func initUI() {
        self.titleLabel?.font   = UIFont.systemFontOfSize(12)
        self.layer.cornerRadius = 2
        self.layer.borderWidth  = 1
        self.layer.borderColor  = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8 ).CGColor
        self.setTitleColor(UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9 ), forState: UIControlState.Normal)
    }
}