//
//  JFSelectNodeView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFSelectNodeViewDelegate: NSObjectProtocol {
    func didTappedAppButton(button: UIButton)
    func didTappedWebButton(button: UIButton)
}

class JFSelectNodeView: UIView {
    
    @IBOutlet weak var appButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    
    weak var delegate: JFSelectNodeViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        appButton.layer.cornerRadius = 10
        appButton.layer.masksToBounds = true
        webButton.layer.cornerRadius = 10
        webButton.layer.masksToBounds = true
    }
    
    /**
     点击了app节点
     */
    @IBAction func didTappedAppButton(sender: UIButton) {
        dismiss()
        appButton.selected = true
        webButton.selected = false
        delegate?.didTappedAppButton(sender)
    }
    
    /**
     点击了web节点
     */
    @IBAction func didTappedWebButton(sender: UIButton) {
        dismiss()
        webButton.selected = true
        appButton.selected = false
        delegate?.didTappedWebButton(sender)
    }
    
    /**
     点击了背景视图
     */
    @objc private func didTappedBgView() {
        dismiss()
    }
    
    /**
     弹出节点选择视图
     */
    func show() {
        UIApplication.sharedApplication().keyWindow?.addSubview(bgView)
        bgView.alpha = 0
        frame = CGRect(x: (SCREEN_WIDTH - SCREEN_WIDTH * 0.5) * 0.5, y: -40, width: SCREEN_WIDTH * 0.5, height: 40)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        UIView.animateWithDuration(0.4) {
            self.bgView.alpha = 1
            self.frame = CGRect(x: (SCREEN_WIDTH - SCREEN_WIDTH * 0.5) * 0.5, y: (SCREEN_HEIGHT - 40) * 0.6, width: SCREEN_WIDTH * 0.5, height: 40)
        }
    }
    
    /**
     隐藏节点选择
     */
    func dismiss() {
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
            self.bgView.alpha = 0
            self.frame = CGRect(x: (SCREEN_WIDTH - SCREEN_WIDTH * 0.5) * 0.5, y: SCREEN_HEIGHT, width: SCREEN_WIDTH * 0.5, height: 40)
            }) { (_) in
                self.bgView.removeFromSuperview()
                self.removeFromSuperview()
        }
    }
    
    /// 背景
    lazy var bgView: UIView = {
        let view = UIView(frame: SCREEN_BOUNDS)
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView)))
        return view
    }()
    

}
