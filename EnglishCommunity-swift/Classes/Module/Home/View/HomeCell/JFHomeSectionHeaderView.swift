//
//  JFHomeSectionHeaderView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFHomeSectionHeaderViewDelegate: NSObjectProtocol {
    func didTappedMoreButton(section: Int)
}

class JFHomeSectionHeaderView: UIView {
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: JFHomeSectionHeaderViewDelegate?
    
    // 当前组
    var section = 0
    
    /**
     点击了更多按钮
     */
    @IBAction func didTappedMoreButton(sender: UIButton) {
        delegate?.didTappedMoreButton(section)
    }
    
}
