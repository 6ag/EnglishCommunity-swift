//
//  JFMusicPlayerView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 9/18/16.
//  Copyright © 2016 zhoujianfeng. All rights reserved.
//

import UIKit

protocol JFMusicPlayerViewDelegate: NSObjectProtocol {
    func didTappedPlayButton(button: UIButton)
}

class JFMusicPlayerView: UIView {

    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    weak var delegate: JFMusicPlayerViewDelegate?
    
    /**
     点击了播放按钮
     */
    @IBAction func didTappedPlayButton(sender: UIButton) {
        delegate?.didTappedPlayButton(sender)
    }
}
