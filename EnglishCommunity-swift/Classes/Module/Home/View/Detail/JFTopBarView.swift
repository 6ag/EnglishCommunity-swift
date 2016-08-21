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
    
    @IBAction func didTappedMenuButton() {
        delegate?.didSelectedMenuButton()
        menuButton.selected = true
        commentButton.selected = false
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.lineView.transform = CGAffineTransformIdentity
        }) { (_) in
            
        }
    }
    
    @IBAction func didTappedCommentButton() {
        delegate?.didSelectedCommentButton()
        commentButton.selected = true
        menuButton.selected = false
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.lineView.transform = CGAffineTransformMakeTranslation(self.commentButton.x - self.menuButton.x, 0)
        }) { (_) in
            
        }
    }
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var lineView: UIImageView!
    weak var delegate: JFTopBarViewDelegate?

}
