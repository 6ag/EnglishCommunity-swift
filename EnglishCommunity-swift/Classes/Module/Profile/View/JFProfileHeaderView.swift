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
    func didTappedDownloadButton()
    func didTappedFriendButton()
    func didTappedMessageButton()
    func didTappedInfoButton()
}

class JFProfileHeaderView: UIView {

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: JFProfileHeaderViewDelegate?
    
    @IBAction func didTappedAvatarButton() {
        delegate?.didTappedAvatarButton(avatarButton)
    }
    
    @IBAction func didTappedDownloadButton() {
        delegate?.didTappedDownloadButton()
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
    }
    
}
