//
//  JFPlaceholderTextView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFPlaceholderTextView: UITextView {
    
    // MARK: - 属性
    /// 占位文本
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.font = font
            placeholderLabel.sizeToFit()
        }
    }

    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        prepareUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JFPlaceholderTextView.textDidChange), name: UITextViewTextDidChangeNotification, object: self)
    }
    
    // 移除通知
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // 自己文字改变了
    func textDidChange() {
        // 能到这里来说明是当前这个textView文本改变了
        // 判断文本是否为空: hasText()
        // 当有文字的时候就隐藏
        placeholderLabel.hidden = hasText()
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        addSubview(placeholderLabel)
        
        placeholderLabel.snp_makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(8)
        }
    }
    
    // MARK: - 懒加载
    // 添加占位文本
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
}