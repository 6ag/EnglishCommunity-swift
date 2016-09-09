//
//  JFDetailVideoCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/6.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFDetailVideoCellDelegate: NSObjectProtocol {
    func didTappedDownloadButton(cell: JFDetailVideoCell, button: UIButton)
}

class JFDetailVideoCell: UITableViewCell {
    
    weak var delegate: JFDetailVideoCellDelegate?

    var model: JFVideo? {
        didSet {
            guard let model = model else {
                return
            }
            
            videoTitleLabel.text = model.title
            
            // 改变状态
            switch model.state {
            case VideoState.NoDownload:
                
                downloadButton.selected = false
                progressView.removeFromSuperview()
                
            case VideoState.AlreadyDownload:
                
                downloadButton.selected = true
                progressView.removeFromSuperview()
                
            case VideoState.Downloading:
                
                if progressView.superview == nil {
                    downloadButton.addSubview(progressView)
                }
                
                progressView.progress = model.progress / 100.0
                print(progressView.progress)
                
            }
            
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        videoTitleLabel.textColor = selected ? UIColor.colorWithHexString("41ca61") : UIColor.colorWithHexString("6b6b6b")
        indicatorButton.selected = selected
    }
    
    /**
     点击了下载按钮
     */
    @IBAction func didTappedDownloadButton(sender: UIButton) {
        delegate?.didTappedDownloadButton(self, button: sender)
    }
    
    @IBOutlet weak var indicatorButton: UIButton!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    /// 进度圈
    lazy var progressView: JFProgressView = {
        let progressView = JFProgressView(frame: CGRect(x: 12, y: 12, width: 20, height: 20))
        progressView.userInteractionEnabled = false
        progressView.backgroundColor = UIColor.whiteColor()
        self.downloadButton.addSubview(progressView)
        return progressView
    }()
    
}
