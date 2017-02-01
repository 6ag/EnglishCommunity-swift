//
//  JFVideoDownloadBottomView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/24.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFVideoDownloadBottomViewDelegate: NSObjectProtocol {
    func didTappedSelectButton(_ button: UIButton)
    func didTappedConfirmButton(_ button: UIButton)
}

class JFVideoDownloadBottomView: UIView {
    
    weak var delegate: JFVideoDownloadBottomViewDelegate?
    
    /**
     点击选择
     */
    @IBAction func didTappedSelectButton(_ sender: UIButton) {
        delegate?.didTappedSelectButton(sender)
    }

    /**
     点击确认下载
     */
    @IBAction func didTappedConfirmButton(_ sender: UIButton) {
        delegate?.didTappedConfirmButton(sender)
    }
}
