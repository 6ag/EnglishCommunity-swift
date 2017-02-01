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
    fileprivate func prepareUI() {
        
        addSubview(titleLabel)
        addSubview(settingButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(30)
        }
        
        settingButton.snp.makeConstraints { (make) in
            make.right.equalTo(-5)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    weak var delegate: JFProfileNavigationBarViewDelegate?
    
    /**
     标题和状态栏改变
     */
    func titleColorChange(_ normal: Bool) {
        if normal {
            titleLabel.isHidden = true
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        } else {
            titleLabel.isHidden = false
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        }
    }
    
    /**
     item改变
     */
    func itemColorChange(_ normal: Bool) {
        if normal {
            settingButton.setImage(UIImage(named: "profile_setting_icon_normal"), for: UIControlState())
//            settingButton.setImage(UIImage(named: "profile_setting_icon_highlighted"), forState: .Highlighted)
        } else {
            settingButton.setImage(UIImage(named: "profile_setting_icon_dark"), for: UIControlState())
//            settingButton.setImage(UIImage(named: "profile_setting_icon_highlighted"), forState: .Highlighted)
        }
    }
    
    /**
     点击了设置
     */
    @objc fileprivate func didTappedSetting() {
        delegate?.didTappedSetting()
    }
    
    // MARK: - 懒加载
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "收藏课程"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.colorWithHexString("24262F")
        label.isHidden = true
        return label
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_setting_icon_normal"), for: UIControlState())
        button.setImage(UIImage(named: "profile_setting_icon_highlighted"), for: .highlighted)
        button.addTarget(self, action: #selector(didTappedSetting), for: .touchUpInside)
        return button
    }()
}
