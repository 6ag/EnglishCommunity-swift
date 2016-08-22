//
//  JFMultiTextView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/19.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFMultiTextViewDelegate: NSObjectProtocol {
    func didTappedSendButton(text: String)
}

class JFMultiTextView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedMultiTextView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: JFMultiTextViewDelegate?
    
    /// 最大高度
    var MaxTextViewHeight: CGFloat = 80
    
    /// 占位文字
    var placeholderString = "请输入评论内容" {
        didSet {
            placeholderLabel.text = placeholderString
        }
    }
    
    /// 自身高度
    var selfHeight: CGFloat {
        if haveNavigationBar {
            return 64 + normalHeight
        }
        return normalHeight
    }
    
    var normalHeight: CGFloat = 40
    
    var fontSize: CGFloat = 16
    
    /// 是否有导航栏
    var haveNavigationBar = false {
        didSet {
            if haveNavigationBar {
                frame = CGRect(x: 0, y: SCREEN_HEIGHT - selfHeight, width: SCREEN_WIDTH, height: normalHeight)
            } else {
                frame = CGRect(x: 0, y: SCREEN_HEIGHT - selfHeight, width: SCREEN_WIDTH, height: normalHeight)
            }
        }
    }
    
    /**
     展开键盘并获取第一响应者
     */
    func expansion() {
        textView.becomeFirstResponder()
    }
    
    /**
     收缩键盘并辞去第一响应者
     */
    func contract() {
        textView.resignFirstResponder()
    }
    
    /**
     移除所有通知
     */
    func removeAllNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
     空白部分触摸事件
     */
    @objc private func didTappedMultiTextView() {
        contract()
    }
    
    /**
     点击了表情按钮
     */
    @objc private func didTappedEmotionButton() {
        contract()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(250 * USEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.textView.inputView = self.textView.inputView == nil ? self.emotionView : nil
            if self.textView.inputView == nil {
                self.emotionButton.setImage(UIImage(named: "emotion_btn_icon"), forState: .Normal)
            } else {
                self.emotionButton.setImage(UIImage(named: "keyboard_btn_icon"), forState: .Normal)
            }
            self.expansion()
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        placeholderLabel.text = placeholderString
        addSubview(backgroundView)
        backgroundView.addSubview(textView)
        backgroundView.addSubview(placeholderLabel)
        backgroundView.addSubview(emotionButton)
        
        textView.snp_makeConstraints { (make) in
            make.left.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(SCREEN_WIDTH - 45)
        }
        
        placeholderLabel.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(5)
            make.height.equalTo(30)
        }
        
        emotionButton.snp_makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.width.equalTo(normalHeight)
        }
    }
    
    /**
     键盘即将显示
     */
    @objc private func keyboardWillShow(notification: NSNotification) {
        frame = SCREEN_BOUNDS
        // 获取键盘的高度
        let userInfo = notification.userInfo!
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRect = value.CGRectValue()
        let height = keyboardRect.size.height
        
        if textView.text.characters.count == 0 {
            backgroundView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - height - selfHeight, width: SCREEN_WIDTH, height: normalHeight)
        } else {
            let rect = CGRect(x: 0, y: SCREEN_HEIGHT - backgroundView.height - height - 64, width: SCREEN_WIDTH, height: backgroundView.height)
            backgroundView.frame = rect
        }
    }
    
    /**
     键盘即将隐藏
     */
    @objc private func keyboardWillHide(notification: NSNotification) {
        if textView.text.characters.count == 0 {
            backgroundView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: normalHeight)
            frame = CGRect(x: 0, y: SCREEN_HEIGHT - selfHeight, width: SCREEN_WIDTH, height: normalHeight)
        } else {
            let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: backgroundView.height)
            backgroundView.frame = rect
            frame = CGRect(x: 0, y: SCREEN_HEIGHT - rect.height - 64, width: SCREEN_WIDTH, height: backgroundView.height)
        }
    }

    // 当文字大于限定高度之后的状态
    var status = false
    
    // MARK: - 懒加载
    /// 背景
    lazy var backgroundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40))
        view.backgroundColor = COLOR_ALL_BG
        view.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).CGColor
        view.layer.borderWidth = 1
        return view
    }()
    
    /// 文本框
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(self.fontSize)
        textView.delegate = self
        textView.layer.cornerRadius = 5
        textView.returnKeyType = .Send
        textView.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).CGColor
        textView.layer.borderWidth = 1
        return textView
    }()
    
    /// 占位字符
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(self.fontSize)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    /// 表情按钮
    lazy var emotionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "emotion_btn_icon"), forState: .Normal)
        button.addTarget(self, action: #selector(didTappedEmotionButton), forControlEvents: .TouchUpInside)
        return button
    }()
    
    /// 表情键盘
    private lazy var emotionView: JFEmoticonView = {
        let view = JFEmoticonView()
        view.textView = self.textView
        return view
    }()

}

// MARK: - UITextViewDelegate
extension JFMultiTextView: UITextViewDelegate {
    
    /**
     textView内容上下滑动
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !status {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    /**
     文本已经改变
     */
    func textViewDidChange(textView: UITextView) {
        
        // 设置占位符和按钮交互
        if textView.text.characters.count == 0 {
            placeholderLabel.text = placeholderString
        } else {
            placeholderLabel.text = ""
        }
        
        let size = CGSize(width: SCREEN_WIDTH - 65, height: CGFloat.max)
        let dict = [NSFontAttributeName : UIFont.systemFontOfSize(fontSize)]
        let currentHeight = (textView.emoticonText() as NSString).boundingRectWithSize(size, options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], attributes: dict, context: nil).size.height
        let y = CGRectGetMaxY(backgroundView.frame)
        if currentHeight < 19.094 {
            status = false
            backgroundView.frame = CGRect(x: 0, y: y - normalHeight, width: SCREEN_WIDTH, height: normalHeight)
        } else if currentHeight < MaxTextViewHeight {
            status = false
            backgroundView.frame = CGRect(x: 0, y: y - textView.contentSize.height - 10, width: SCREEN_WIDTH, height: textView.contentSize.height + 10)
        } else {
            status = true
        }
        
    }
    
    /**
     监听回车按钮
     */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.didTappedSendButton(textView.emoticonText())
            contract()
            textView.text = ""
            placeholderLabel.text = placeholderString
            frame = CGRect(x: 0, y: SCREEN_HEIGHT - selfHeight, width: SCREEN_WIDTH, height: normalHeight)
            backgroundView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: normalHeight)
            return false
        }
        return true
    }
    
}
