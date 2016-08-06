//
//  JFDetailHeaderView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/6.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFDetailHeaderView: UIView {

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        let names = ["线路", "分享", "收藏", "缓存"]
        let images = ["publish-audio", "publish-offline", "publish-picture", "publish-review"]
        
        for index in 10...13 {
            let button = JFDetailHeaderButton(type: .Custom)
            button.tag = index
            button.setTitle(names[index - 10], forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)
            button.setImage(UIImage(named: images[index - 10]), forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(16)
            button.addTarget(self, action: #selector(didTappedButton(_:)), forControlEvents: .TouchUpInside)
            addSubview(button)
        }
    }
    
    /**
     点击了按钮
     */
    @objc private func didTappedButton(button: JFDetailHeaderButton) {
        print(button.tag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let y: CGFloat = 0
        let height = self.height
        let width = self.width / CGFloat(subviews.count)
        
        for view in subviews {
            let x = CGFloat(view.tag - 10) * width
            view.frame = CGRect(x: x, y: y, width: width, height: height)
            print(view.frame)
        }
        
    }
    

}
