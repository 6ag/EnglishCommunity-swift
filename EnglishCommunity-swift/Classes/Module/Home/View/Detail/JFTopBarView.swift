//
//  JFTopBarView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/6.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFTopBarViewDelegate: NSObjectProtocol {
    func didSelectedMenuButton()
    func didSelectedCommentButton()
}

class JFTopBarView: UIView {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var lineView: UIImageView!
    weak var delegate: JFTopBarViewDelegate?

    @IBAction func didTappedMenuButton() {
        delegate?.didSelectedMenuButton()
        menuButton.isSelected = true
        commentButton.isSelected = false
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.lineView.transform = CGAffineTransform.identity
        }) { (_) in
            
        }
    }
    
    @IBAction func didTappedCommentButton() {
        delegate?.didSelectedCommentButton()
        commentButton.isSelected = true
        menuButton.isSelected = false
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.lineView.transform = CGAffineTransform(translationX: self.commentButton.x - self.menuButton.x, y: 0)
        }) { (_) in
            
        }
    }
    
}
