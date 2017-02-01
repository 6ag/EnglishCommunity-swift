//
//  JFEmoticonView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/19.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFEmoticonView: UIView {
    
    /// 表情区域高度
    fileprivate var collectionHeight: CGFloat = 172
    
    /// 工具条高度
    fileprivate var toolBarHeight: CGFloat = 44
    
    /// 记录当前选中高亮的按钮
    fileprivate var selectedButton: UIButton?
    
    /// 按钮的起始tag
    fileprivate let baseTag = 1000
    
    // MARK: - 属性
    fileprivate var collectionViewCellIdentifier = "collectionViewCellIdentifier"
    
    /// textView
    weak var textView: UITextView?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: collectionHeight + toolBarHeight))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 准备UI
    fileprivate func prepareUI() {
        
        setupToolBar()
        setupCollectionView()
        
        addSubview(collectionView)
        addSubview(toolBar)
        
        toolBar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(toolBarHeight)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(toolBar.snp.top)
            make.height.equalTo(collectionHeight)
        }
        
    }
    
    /// 设置toolBar
    fileprivate func setupToolBar() {
        // 记录 item 的位置
        var index = 0
        var items = [UIBarButtonItem]()
        // 根据加载到的表情包名称显示
        for package in packages {
            // 获取表情包名称
            let name = package.group_name_cn
            
            let button = UIButton()
            button.setTitle(name, for: UIControlState())
            button.setTitleColor(UIColor.lightGray, for: UIControlState())
            button.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
            button.setTitleColor(UIColor.darkGray, for: UIControlState.selected)
            button.sizeToFit()
            button.tag = index + baseTag
            button.addTarget(self, action: #selector(itemClick(_:)), for: UIControlEvents.touchUpInside)
            if index == 0 {
                switchSelectedButton(button)
            }
            
            // 创建 barbuttomitem
            let item = UIBarButtonItem(customView: button)
            items.append(item)
            
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
            
            index += 1
        }
        
        // 移除最后一个多有的弹簧
        items.removeLast()
        
        toolBar.items = items
    }
    
    /**
     处理toolBar点击事件
     */
    func itemClick(_ button: UIButton) {
        let indexPath = IndexPath(item: 0, section: button.tag - baseTag)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
        switchSelectedButton(button)
    }
    
    /**
     使按钮高亮
     */
    fileprivate func switchSelectedButton(_ button: UIButton) {
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
    }
    
    /// 设置collectioView
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(JFEmoticonCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
    }
    
    // MARK: - 懒加载
    /// collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        // 流水布局layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: SCREEN_WIDTH / 7.0, height: self.collectionHeight / 3.0)
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    /// toolBar
    fileprivate lazy var toolBar = UIToolbar()
    
    /// 表情包模型
    /// 访问内存中的表情包模型数据
    fileprivate lazy var packages = JFEmoticonPackage.packages
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFEmoticonView: UICollectionViewDataSource, UICollectionViewDelegate {
    // 返回多少组(一个表情包一组)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // packages[section]: 获取对应的表情包
        // packages[section].emoticons?.count 获取对应的表情包里面的表情数量
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath) as! JFEmoticonCell
        let emoticon = packages[indexPath.section].emoticons?[indexPath.item]
        cell.emoticon = emoticon
        return cell
    }
    
    // 监听scrollView滚动,当停下来的时候判断显示的是哪个section
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 获取到正在显示的section -> indexPath
        // 获取到collectionView正在显示的cell的IndexPath
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            let section = indexPath.section
            let button = toolBar.viewWithTag(section + baseTag) as! UIButton
            switchSelectedButton(button)
        }
    }
    
    /*
     将点击的表情插入到textView里面
     1.获取textView
     2.需要知道点击哪个表情
     */
    // collectionView cell的点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 添加表情到textView
        // 获取到表情
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        
        textView?.insertEmoticon(emoticon)
        
        // 当点击最近里面的表情,发现点击的和添加到textView上面的不是同一个,原因是数据发生改变,显示没有变化
        // 1.刷新数据
        
        // 2.当点击的是最近表情包得表情,不添加到最近表情包和排序
        
        if indexPath.section != 0 {
            // 添加 表情模型 到  最近表情包
            JFEmoticonPackage.addFavorate(emoticon)
        }
        
    }
}

// MARK: - 自定义表情cell
class JFEmoticonCell: UICollectionViewCell {
    
    // MARK: - 属性
    /// 表情模型
    var emoticon: JFEmoticon? {
        didSet {
            // 设置内容
            // 设置图片
            if let pngPath = emoticon?.pngPath {
                emoticonButton.setImage(UIImage(contentsOfFile: pngPath), for: UIControlState())
            } else {    // 防止cell复用
                emoticonButton.setImage(nil, for: UIControlState())
            }
            
            // 显示emoji表情
            emoticonButton.setTitle(emoticon?.emoji, for: UIControlState())
            
            // 判断是否是删除按钮模型
            if emoticon!.removeEmoticon {
                // 是删除按钮
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), for: UIControlState())
            }
        }
    }
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    // MARK: - 准备UI
    fileprivate func prepareUI() {
        // 添加子控件
        contentView.addSubview(emoticonButton)
        
        // 设置frame
        emoticonButton.frame = bounds.insetBy(dx: 4, dy: 4)
        
        // 禁止按钮可以点击
        emoticonButton.isUserInteractionEnabled = false
        
        // 设置title大小
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
    
    // MARK: - 懒加载
    /// 表情按钮
    fileprivate lazy var emoticonButton: UIButton = UIButton()
}
