//
//  JFGrammarDetailViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFGrammarDetailViewController: UIViewController {

    /// 语法模型
    var grammar: JFGrammar? {
        didSet {
            titleLabel.text = grammar?.title
            
            let attributedString = NSMutableAttributedString(string: grammar!.content!)
            let paragaphStyle = NSMutableParagraphStyle()
            paragaphStyle.lineSpacing = 3
            paragaphStyle.paragraphSpacing = 8
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragaphStyle, range: NSRange(location: 0, length: grammar!.content!.characters.count))
            contentLabel.attributedText = attributedString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }

    /**
     准备UI
     */
    private func prepareUI() {
        
        title = "详情"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(titleLabel)
        contentScrollView.addSubview(contentLabel)
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.top.equalTo(MARGIN)
            make.width.equalTo(SCREEN_WIDTH - MARGIN - 8)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.left.equalTo(MARGIN)
            make.top.equalTo(titleLabel.snp_bottom).offset(MARGIN)
            make.width.equalTo(titleLabel.snp_width)
        }
        
        view.layoutIfNeeded()
        contentScrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGRectGetMaxY(contentLabel.frame) + MARGIN + 50)
        
        // 底部悬浮广告
        let bannerView = JFAdManager.shareDbManager().getBannerView(self)
        view.addSubview(bannerView)
        bannerView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - 懒加载
    /// 内容滚动视图
    private lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64))
        return contentScrollView
    }()
    
    /// 标题label
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        return titleLabel
    }()
    
    /// 内容label
    private lazy var contentLabel: FFLabel = {
        let contentLabel = FFLabel()
        contentLabel.textColor = UIColor.blackColor()
        contentLabel.font = UIFont.systemFontOfSize(16)
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
    
}
