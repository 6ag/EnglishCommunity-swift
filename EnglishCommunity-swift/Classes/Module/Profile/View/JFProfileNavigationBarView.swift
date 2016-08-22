//
//  JFProfileNavigationBarView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/20.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFProfileNavigationBarViewDelegate: NSObjectProtocol {
    func didTappedSetting()
}

class JFProfileNavigationBarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        addSubview(titleLabel)
        addSubview(settingButton)
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(30)
        }
        
        settingButton.snp_makeConstraints { (make) in
            make.right.equalTo(-5)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    weak var delegate: JFProfileNavigationBarViewDelegate?
    
    /**
     标题和状态栏改变
     */
    func titleColorChange(normal: Bool) {
        if normal {
            titleLabel.hidden = true
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        } else {
            titleLabel.hidden = false
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        }
    }
    
    /**
     item改变
     */
    func itemColorChange(normal: Bool) {
        if normal {
            settingButton.setImage(UIImage(named: "profile_setting_icon_normal"), forState: .Normal)
//            settingButton.setImage(UIImage(named: "profile_setting_icon_highlighted"), forState: .Highlighted)
        } else {
            settingButton.setImage(UIImage(named: "profile_setting_icon_dark"), forState: .Normal)
//            settingButton.setImage(UIImage(named: "profile_setting_icon_highlighted"), forState: .Highlighted)
        }
    }
    
    /**
     点击了设置
     */
    @objc private func didTappedSetting() {
        delegate?.didTappedSetting()
    }
    
    // MARK: - 懒加载
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "收藏课程"
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.colorWithHexString("24262F")
        label.hidden = true
        return label
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "profile_setting_icon_normal"), forState: .Normal)
        button.setImage(UIImage(named: "profile_setting_icon_highlighted"), forState: .Highlighted)
        button.addTarget(self, action: #selector(didTappedSetting), forControlEvents: .TouchUpInside)
        return button
    }()
}
