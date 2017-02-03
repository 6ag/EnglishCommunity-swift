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
    fileprivate var photoSelectorViewBottomCon: NSLayoutConstraint?
    
    /// 内容的最大长度
    fileprivate let tweetsMaxLength = 250
    
    /// 选取的将要被at的用户
    var relationUsers: [JFRelationUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        // 监听键盘frame值改变
        NotificationCenter.default.addObserver(self, selector: #selector(JFPublishViewController.willChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     键盘frame改变
     */
    func willChangeFrame(_ notification: Notification) {
        
        // 获取键盘最终位置
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        
        // 动画时间
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 更新约束
        toolBar.snp.updateConstraints { (make) in
            make.bottom.equalTo(-(SCREEN_HEIGHT - (endFrame?.origin.y ?? 0)))
        }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    // MARK: - 准备UI
    fileprivate func prepareUI() {
        
        view.backgroundColor = UIColor.white
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 如果照片选择器的view没有显示就弹出键盘
        if photoSelectorViewBottomCon?.constant != 0 {
            textView.becomeFirstResponder()
        }
    }
    
    /// 设置导航栏
    fileprivate func setupNavigationBar() {
        
        navigationItem.title = "来一发"        
        navigationItem.leftBarButtonItem = UIBarButtonItem.leftItem("取消", target: self, action: #selector(JFPublishViewController.close))
        navigationItem.rightBarButtonItem = UIBarButtonItem.rightItem("发送", target: self, action: #selector(JFPublishViewController.sendtweets))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    /// 设置toolBar
    fileprivate func setupToolBar() {
        
        toolBar.snp.makeConstraints { (make) in
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
            barButton.setImage(UIImage(named: imageName), for: UIControlState())
            barButton.setImage(UIImage(named: "\(imageName)_highlighted"), for: UIControlState.highlighted)
            barButton.addTarget(self, action: Selector(action), for: UIControlEvents.touchUpInside)
            barButton.sizeToFit()
            let item = UIBarButtonItem(customView: barButton)
            items.append(item)
            
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
            
            index += 1
        }
        
        // 移除最后一个弹簧
        items.removeLast()
        
        toolBar.items = items
    }
    
    /// 设置textView
    fileprivate func setupTextView() {
        
        textView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(toolBar.snp.top)
        }
        
    }
    
    /// 准备 显示微博剩余长度 label
    func prepareLengthTipLabel() {
        
        lengthTipLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-8)
            make.bottom.equalTo(toolBar.snp.top).offset(-8)
        }
        
    }
    
    /// 准备 照片选择器
    func preparePhotoSelectorView() {
        
        // 照片选择器控制器的view
        let photoSelectorView = photoSelectorVC.view
        
        photoSelectorView?.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["psv": photoSelectorView]
        // 添加约束
        // 水平
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[psv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // 高度
        view.addConstraint(NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.height, multiplier: 0.6, constant: 0))
        
        // 底部重合，偏移photoSelectorView的高度
        photoSelectorViewBottomCon = NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: view.frame.height * 0.6)
        
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
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
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
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(250 * USEC_PER_SEC)) / Double(NSEC_PER_SEC)) { () -> Void in
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
    @objc fileprivate func close() {
        
        // 关闭键盘
        textView.resignFirstResponder()
        
        // 关闭sv提示
        JFProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
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
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let results = regex.matches(in: text, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, text.characters.count))
            for result in results {
                resultStrings.append(String((text as NSString).substring(with: result.range).replacingOccurrences(of: "@", with: "")))
            }
        } catch {
            
        }
        
        // 根据当前文本内容，去匹配将要at的用户 - 因为有可能用户插入被at用户后又手动删除
        var atUsers = [[String : AnyObject]]()
        if let relationUsers = relationUsers {
            for relationUser in relationUsers {
                if resultStrings.contains(relationUser.relationNickname!) {
                    let atUser: [String : AnyObject] = [
                        "id" : relationUser.relationUserId as AnyObject,
                        "nickname" : relationUser.relationNickname! as AnyObject
                    ]
                    atUsers.append(atUser)
                }
            }
        }
        
        JFProgressHUD.showWithStatus("正在发送中...")
        JFNetworkTools.shareNetworkTool.sendTweets(text, images: images, atUsers: atUsers) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                JFProgressHUD.showInfoWithStatus("没发出去")
                return
            }
            
            self.close()
        }
        
    }
    
    // MARK: - 懒加载
    /// toolBar
    fileprivate lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor(white: 0.8, alpha: 1)
        return toolBar
    }()
    
    /// textView
    fileprivate lazy var textView: JFPlaceholderTextView = {
        let textView = JFPlaceholderTextView()
        
        // 当textView被拖动的时候就会将键盘退回,textView能拖动
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.black
        textView.bounces = true
        textView.alwaysBounceVertical = true
        textView.placeholder = "今天你来一发了吗？"
        textView.delegate = self
        return textView
    }()
    
    /// 表情键盘
    fileprivate lazy var emotionView: JFEmoticonView = {
        let view = JFEmoticonView()
        view.textView = self.textView
        return view
    }()
    
    /// 显示微博剩余长度
    fileprivate lazy var lengthTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.text = String(self.tweetsMaxLength)
        return label
    }()
    
    /// 照片选择器的控制器
    fileprivate lazy var photoSelectorVC: JFPhotoSelectorViewController = {
        let controller = JFPhotoSelectorViewController()
        self.addChildViewController(controller)
        return controller
    }()
}

// MARK: - UITextViewDelegate
extension JFPublishViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        // 当textView 没有文本的时候,发送按钮不可用
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
        
        // 剩余长度
        let length = tweetsMaxLength - textView.emoticonText().characters.count
        
        lengthTipLabel.text = String(length)
        
        // 判断 length 大于等于0显示灰色, 小于0显示红色
        lengthTipLabel.textColor = length < 0 ? UIColor.red : UIColor.lightGray
    }
}
