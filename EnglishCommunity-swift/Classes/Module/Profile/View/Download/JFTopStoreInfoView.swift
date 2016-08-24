//
//  JFTopStoreInfoView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFTopStoreInfoViewDelegate: NSObjectProtocol {
    func didTappedCloseButton(button: UIButton)
}

class JFTopStoreInfoView: UIView {
    
    weak var delegate: JFTopStoreInfoViewDelegate?
    
    /// 存储信息
    @IBOutlet weak var storeInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storeInfoLabel.text = "已占用" + JFStoreInfoTool.getOccupyDiskSize() + "，" + "剩余" + JFStoreInfoTool.getAvailableDiskSize() + "可用"
    }

    /**
     关闭按钮点击事件
     */
    @IBAction func didTappedCloseButton(sender: UIButton) {
        delegate?.didTappedCloseButton(sender)
    }
    
}
