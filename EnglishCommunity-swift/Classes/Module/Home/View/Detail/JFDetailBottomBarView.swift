//
//  JFDetailBottomBarView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/18.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFDetailBottomBarViewDelegate: NSObjectProtocol {
    
    func didTappedDownloadButton(button: UIButton)
    func didTappedShareButton(button: UIButton)
    func didTappedChangeLineButton(button: UIButton)
    func didTappedJoinCollectionButton(button: UIButton)
}

class JFDetailBottomBarView: UIView {

    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var changeLineButton: UIButton!
    @IBOutlet weak var joinCollectionButton: UIButton!
    
    weak var delegate: JFDetailBottomBarViewDelegate?
    
    @IBAction func didTappedDownloadButton(button: UIButton) {
        delegate?.didTappedDownloadButton(button)
    }
    
    @IBAction func didTappedShareButton(button: UIButton) {
        delegate?.didTappedShareButton(button)
    }
    
    @IBAction func didTappedChangeLineButton(button: UIButton) {
        delegate?.didTappedChangeLineButton(button)
    }
    
    @IBAction func didTappedJoinCollectionButton(button: UIButton) {
        delegate?.didTappedJoinCollectionButton(button)
    }
    
}
