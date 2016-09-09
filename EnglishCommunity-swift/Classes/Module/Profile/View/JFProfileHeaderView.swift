//
//  JFProfileHeaderView.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/20.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

protocol JFProfileHeaderViewDelegate: NSObjectProtocol {
    
    func didTappedAvatarButton(button: UIButton)
    func didTappedFriendButton()
    func didTappedMessageButton()
    func didTappedInfoButton()
}

class JFProfileHeaderView: UIView {

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: JFProfileHeaderViewDelegate?
    @IBOutlet weak var redPointLabel: UILabel!
    
    
    @IBAction func didTappedAvatarButton() {
        delegate?.didTappedAvatarButton(avatarButton)
    }
    
    @IBAction func didTappedFriendButton() {
        delegate?.didTappedFriendButton()
    }
    
    @IBAction func didTappedMessageButton() {
        delegate?.didTappedMessageButton()
    }
    
    @IBAction func didTappedInfoButton() {
        delegate?.didTappedInfoButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarButton.layer.borderColor = UIColor.colorWithHexString("58D475").CGColor
        avatarButton.layer.borderWidth = 4
        
        redPointLabel.layer.cornerRadius = 7.5
        redPointLabel.layer.masksToBounds = true
    }
    
}
