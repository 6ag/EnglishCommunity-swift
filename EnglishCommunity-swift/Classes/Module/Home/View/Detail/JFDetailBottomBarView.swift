//
//  JFDetailBottomBarView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/18.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFDetailBottomBarViewDelegate: NSObjectProtocol {
    
    func didTappedDownloadButton(_ button: UIButton)
    func didTappedShareButton(_ button: UIButton)
    func didTappedChangeLineButton(_ button: UIButton)
    func didTappedJoinCollectionButton(_ button: UIButton)
}

class JFDetailBottomBarView: UIView {

    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var changeLineButton: UIButton!
    @IBOutlet weak var joinCollectionButton: UIButton!
    
    weak var delegate: JFDetailBottomBarViewDelegate?
    
    @IBAction func didTappedDownloadButton(_ button: UIButton) {
        delegate?.didTappedDownloadButton(button)
    }
    
    @IBAction func didTappedShareButton(_ button: UIButton) {
        delegate?.didTappedShareButton(button)
    }
    
    @IBAction func didTappedChangeLineButton(_ button: UIButton) {
        delegate?.didTappedChangeLineButton(button)
    }
    
    @IBAction func didTappedJoinCollectionButton(_ button: UIButton) {
        delegate?.didTappedJoinCollectionButton(button)
    }
    
}
