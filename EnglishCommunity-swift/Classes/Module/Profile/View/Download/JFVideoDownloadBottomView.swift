//
//  JFVideoDownloadBottomView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFVideoDownloadBottomViewDelegate: NSObjectProtocol {
    func didTappedSelectButton(button: UIButton)
    func didTappedConfirmButton(button: UIButton)
}

class JFVideoDownloadBottomView: UIView {
    
    weak var delegate: JFVideoDownloadBottomViewDelegate?
    
    /**
     点击选择
     */
    @IBAction func didTappedSelectButton(sender: UIButton) {
        delegate?.didTappedSelectButton(sender)
    }

    /**
     点击确认下载
     */
    @IBAction func didTappedConfirmButton(sender: UIButton) {
        delegate?.didTappedConfirmButton(sender)
    }
}
