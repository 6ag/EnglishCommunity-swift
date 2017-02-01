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
    func didTappedSendButton(_ text: String)
}

class JFMultiTextView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     空白部分触摸事件
     */
    @objc fileprivate func didTappedMultiTextView() {
        contract()
    }
    
    /**
     点击了表情按钮
     */
    @objc fileprivate func didTappedEmotionButton() {
        contract()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(250 * USEC_PER_SEC)) / Double(NSEC_PER_SEC)) { () -> Void in
            self.textView.inputView = self.textView.inputView == nil ? self.emotionView : nil
            if self.textView.inputView == nil {
                self.emotionButton.setImage(UIImage(named: "emotion_btn_icon"), for: UIControlState())
            } else {
                self.emotionButton.setImage(UIImage(named: "keyboard_btn_icon"), for: UIControlState())
            }
            self.expansion()
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        placeholderLabel.text = placeholderString
        addSubview(backgroundView)
        backgroundView.addSubview(textView)
        backgroundView.addSubview(placeholderLabel)
        backgroundView.addSubview(emotionButton)
        
        textView.snp.makeConstraints { (make) in
            make.left.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(SCREEN_WIDTH - 45)
        }
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(5)
            make.height.equalTo(30)
        }
        
        emotionButton.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.width.equalTo(normalHeight)
        }
    }
    
    /**
     键盘即将显示
     */
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        frame = SCREEN_BOUNDS
        // 获取键盘的高度
        let userInfo = notification.userInfo!
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRect = value.cgRectValue
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
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
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
        view.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    /// 文本框
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: self.fontSize)
        textView.delegate = self
        textView.layer.cornerRadius = 5
        textView.returnKeyType = .send
        textView.layer.borderColor = UIColor(white: 0.7, alpha: 0.5).cgColor
        textView.layer.borderWidth = 1
        return textView
    }()
    
    /// 占位字符
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: self.fontSize)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    /// 表情按钮
    lazy var emotionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "emotion_btn_icon"), for: UIControlState())
        button.addTarget(self, action: #selector(didTappedEmotionButton), for: .touchUpInside)
        return button
    }()
    
    /// 表情键盘
    fileprivate lazy var emotionView: JFEmoticonView = {
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !status {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    /**
     文本已经改变
     */
    func textViewDidChange(_ textView: UITextView) {
        
        // 设置占位符和按钮交互
        if textView.text.characters.count == 0 {
            placeholderLabel.text = placeholderString
        } else {
            placeholderLabel.text = ""
        }
        
        let size = CGSize(width: SCREEN_WIDTH - 65, height: CGFloat.greatestFiniteMagnitude)
        let dict = [NSFontAttributeName : UIFont.systemFont(ofSize: fontSize)]
        let currentHeight = (textView.emoticonText() as NSString).boundingRect(with: size, options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: dict, context: nil).size.height
        let y = backgroundView.frame.maxY
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
