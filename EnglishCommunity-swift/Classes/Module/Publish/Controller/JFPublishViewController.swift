//
//  JFPublishViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFPublishViewController: UIViewController {
    
    // MARK: - 属性
    /// 照片选择器控制器view的底部约束
    private var photoSelectorViewBottomCon: NSLayoutConstraint?
    
    /// 内容的最大长度
    private let tweetsMaxLength = 250
    
    /// 选取的将要被at的用户
    var relationUsers: [JFRelationUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        // 监听键盘frame值改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JFPublishViewController.willChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     键盘frame改变
     */
    func willChangeFrame(notification: NSNotification) {
        
        // 获取键盘最终位置
        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        
        // 动画时间
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        
        // 更新约束
        toolBar.snp_updateConstraints { (make) in
            make.bottom.equalTo(-(SCREEN_HEIGHT - endFrame.origin.y))
        }
        
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(textView)
        view.addSubview(photoSelectorVC.view)
        view.addSubview(toolBar)
        view.addSubview(lengthTipLabel)
        
        setupNavigationBar()
        setupTextView()
        preparePhotoSelectorView()
        setupToolBar()
        prepareLengthTipLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 如果照片选择器的view没有显示就弹出键盘
        if photoSelectorViewBottomCon?.constant != 0 {
            textView.becomeFirstResponder()
        }
    }
    
    /// 设置导航栏
    private func setupNavigationBar() {
        
        navigationItem.title = "来一发"        
        navigationItem.leftBarButtonItem = UIBarButtonItem.leftItem("取消", target: self, action: #selector(JFPublishViewController.close))
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem("发送", target: self, action: #selector(JFPublishViewController.sendtweets))
        navigationItem.rightBarButtonItem?.enabled = false
        
    }
    
    /// 设置toolBar
    private func setupToolBar() {
        
        toolBar.snp_makeConstraints { (make) in
            make.left.bottom.equalTo(0)
            make.size.equalTo(CGSize(width: SCREEN_WIDTH, height: 44))
        }
        
        // 创建toolBar item
        var items = [UIBarButtonItem]()
        
        // 每个item对应的图片名称
        let itemSettings = [["imageName": "compose_camerabutton_background", "action": "camera"],
                            ["imageName": "compose_toolbar_picture", "action": "picture"],
                            ["imageName": "compose_trendbutton_background", "action": "trend"],
                            ["imageName": "compose_mentionbutton_background", "action": "mention"],
                            ["imageName": "compose_emoticonbutton_background", "action": "emoticon"]]
        var index = 0
        
        // 遍历 itemSettings 获取图片名称,创建items
        for dict in itemSettings {
            // 获取图片的名称
            let imageName = dict["imageName"]!
            
            // 获取图片对应点点击方法名称
            let action = dict["action"]!
            
            let barButton = UIButton()
            barButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
            barButton.setImage(UIImage(named: "\(imageName)_highlighted"), forState: UIControlState.Highlighted)
            barButton.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchUpInside)
            barButton.sizeToFit()
            let item = UIBarButtonItem(customView: barButton)
            items.append(item)
            
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
            
            index += 1
        }
        
        // 移除最后一个弹簧
        items.removeLast()
        
        toolBar.items = items
    }
    
    /// 设置textView
    private func setupTextView() {
        
        textView.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(toolBar.snp_top)
        }
        
    }
    
    /// 准备 显示微博剩余长度 label
    func prepareLengthTipLabel() {
        
        lengthTipLabel.snp_makeConstraints { (make) in
            make.right.equalTo(-8)
            make.bottom.equalTo(toolBar.snp_top).offset(-8)
        }
        
    }
    
    /// 准备 照片选择器
    func preparePhotoSelectorView() {
        
        // 照片选择器控制器的view
        let photoSelectorView = photoSelectorVC.view
        
        photoSelectorView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["psv": photoSelectorView]
        // 添加约束
        // 水平
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[psv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // 高度
        view.addConstraint(NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.6, constant: 0))
        
        // 底部重合，偏移photoSelectorView的高度
        photoSelectorViewBottomCon = NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: view.frame.height * 0.6)
        
        view.addConstraint(photoSelectorViewBottomCon!)
    }
    
    // MARK: - 按钮点击事件
    /**
     拍照
     */
    func camera() {
        photoSelectorVC.takePhoto()
        
        // 让照片选择器的view移动上来
        photoSelectorViewBottomCon?.constant = 0
        
        // 退下键盘
        textView.resignFirstResponder()
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    /**
     图片
     */
    func picture() {
        
        photoSelectorVC.selectPhoto()
        
        // 让照片选择器的view移动上来
        photoSelectorViewBottomCon?.constant = 0
        
        // 退下键盘
        textView.resignFirstResponder()
        
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    /**
     话题 #话题#
     */
    func trend() {
        textView.becomeFirstResponder()
        let selectStart = textView.selectedRange.location + 1
        textView.insertText("#请输入教程标题或话题#")
        textView.selectedRange = NSRange(location: selectStart, length: 10)
    }
    
    /**
     谈到某人 @人
     */
    func mention() {
        textView.resignFirstResponder()
        let selectFriendVc = JFSelectFriendViewController()
        selectFriendVc.callback = {(relationUsers: [JFRelationUser]?) -> Void in
            
            guard let relationUsers = relationUsers else {
                return
            }
            
            self.relationUsers = relationUsers
            
            for relationUser in relationUsers {
                self.textView.insertText("@\(relationUser.relationNickname!) ")
            }
            
        }
        navigationController?.pushViewController(selectFriendVc, animated: true)
    }
    
    /// 切换表情键盘
    func emoticon() {
        
        textView.resignFirstResponder()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(250 * USEC_PER_SEC)), dispatch_get_main_queue()) { () -> Void in
            self.textView.inputView = self.textView.inputView == nil ? self.emotionView : nil
            if self.textView.inputView == nil {
//                self.emotionButton.setImage(UIImage(named: "emotion_btn_icon"), forState: .Normal)
            } else {
//                self.emotionButton.setImage(UIImage(named: "keyboard_btn_icon"), forState: .Normal)
            }
            
            self.textView.becomeFirstResponder()
        }
    }
    
    /// 关闭控制器
    @objc private func close() {
        
        // 关闭键盘
        textView.resignFirstResponder()
        
        // 关闭sv提示
        JFProgressHUD.dismiss()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     发布动弹
     */
    func sendtweets() {
        
        let text = textView.emoticonText()
        let images = photoSelectorVC.photos
        
        if text.characters.count > tweetsMaxLength {
            JFProgressHUD.showInfoWithStatus("微博长度超出")
            return
        }
        
        // 匹配当前文本框中的 @数量
        var resultStrings = [String]()
        do {
            let pattern = "@\\S*"
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            let results = regex.matchesInString(text, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, text.characters.count))
            for result in results {
                resultStrings.append(String((text as NSString).substringWithRange(result.range).stringByReplacingOccurrencesOfString("@", withString: "")))
            }
        } catch {
            
        }
        
        // 根据当前文本内容，去匹配将要at的用户 - 因为有可能用户插入被at用户后又手动删除
        var atUsers = [[String : AnyObject]]()
        if let relationUsers = relationUsers {
            for relationUser in relationUsers {
                if resultStrings.contains(relationUser.relationNickname!) {
                    let atUser: [String : AnyObject] = [
                        "id" : relationUser.relationUserId,
                        "nickname" : relationUser.relationNickname!
                    ]
                    atUsers.append(atUser)
                }
            }
        }
        
        JFProgressHUD.showWithStatus("正在发送中...")
        JFNetworkTools.shareNetworkTool.sendTweets(text, images: images, atUsers: atUsers) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                print(success, error)
                JFProgressHUD.showInfoWithStatus("没发出去")
                return
            }
            
            self.close()
        }
        
    }
    
    // MARK: - 懒加载
    /// toolBar
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return toolBar
    }()
    
    /// textView
    private lazy var textView: JFPlaceholderTextView = {
        let textView = JFPlaceholderTextView()
        
        // 当textView被拖动的时候就会将键盘退回,textView能拖动
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        textView.font = UIFont.systemFontOfSize(16)
        textView.textColor = UIColor.blackColor()
        textView.bounces = true
        textView.alwaysBounceVertical = true
        textView.placeholder = "今天你来一发了吗？"
        textView.delegate = self
        return textView
    }()
    
    /// 表情键盘
    private lazy var emotionView: JFEmoticonView = {
        let view = JFEmoticonView()
        view.textView = self.textView
        return view
    }()
    
    /// 显示微博剩余长度
    private lazy var lengthTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        label.text = String(self.tweetsMaxLength)
        return label
    }()
    
    /// 照片选择器的控制器
    private lazy var photoSelectorVC: JFPhotoSelectorViewController = {
        let controller = JFPhotoSelectorViewController()
        self.addChildViewController(controller)
        return controller
    }()
}

// MARK: - UITextViewDelegate
extension JFPublishViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        
        // 当textView 没有文本的时候,发送按钮不可用
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        
        // 剩余长度
        let length = tweetsMaxLength - textView.emoticonText().characters.count
        
        lengthTipLabel.text = String(length)
        
        // 判断 length 大于等于0显示灰色, 小于0显示红色
        lengthTipLabel.textColor = length < 0 ? UIColor.redColor() : UIColor.lightGrayColor()
    }
}
