//
//  JFProfileHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/20.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFInfoHeaderViewDelegate: NSObjectProtocol {
    func didTappedAvatarButton()
}

class JFInfoHeaderView: UIView {

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: JFInfoHeaderViewDelegate?
    
    @IBAction func didTappedAvatarButton() {
        delegate?.didTappedAvatarButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarButton.layer.borderColor = UIColor.colorWithHexString("58D475").CGColor
        avatarButton.layer.borderWidth = 4
    }
    
}
