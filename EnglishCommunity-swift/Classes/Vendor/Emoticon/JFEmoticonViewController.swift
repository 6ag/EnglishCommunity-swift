//
//  JFEmoticonViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

// 使用控制器的view作为textView的自定义键盘,控制器view的大小在 viewDidAppear 方法里面才确定
class JFEmoticonViewController: UIViewController {
    
    // MARK: - 属性
    private var collectionViewCellIdentifier = "collectionViewCellIdentifier"
    
    /// textView
    weak var textView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = UIColor.redColor()
        prepareUI()
        
//        print("viewDidLoad view.frame:\(view.frame)")
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        print("viewWillAppear view.frame:\(view.frame)")
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        print("viewDidAppear view.frame:\(view.frame)")
//    }
//    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        // 添加约束
        // 手动添加约束
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["cv" : collectionView, "tb" : toolBar]
        // VFL
        // collectionView水平方向
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        // toolBar水平方向
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tb]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // 垂直方向
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cv]-[tb(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        setupToolBar()
        
        setupCollectionView()
    }
    
    /// 设置toolBar
    private func setupToolBar() {
        
        // 记录 item 的位置
        var index = 0
        var items = [UIBarButtonItem]()
        // 根据加载到的表情包名称显示
        for package in packages {
            // 获取表情包名称
            let name = package.group_name_cn
            
            let button = UIButton()
            
            // 设置标题
            button.setTitle(name, forState: UIControlState.Normal)
            
            // 设置颜色
            button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
            button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Selected)
            
            button.sizeToFit()
            
            // 设置tag, 加载基准的tag 1000
            button.tag = index + baseTag
            
            // 让最近表情包高亮
            if index == 0 {
                switchSelectedButton(button)
            }
            
            // 添加点击事件
            button.addTarget(self, action: #selector(JFEmoticonViewController.itemClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            // 创建 barbuttomitem
            let item = UIBarButtonItem(customView: button)
            
            items.append(item)
            
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
            
            index += 1
        }
        
        // 移除最后一个多有的弹簧
        items.removeLast()
        
        toolBar.items = items
    }
    
    // 处理toolBar点击事件
    func itemClick(button: UIButton) {
//        print("button.tag:\(button.tag)")
        
        // button.tag 是加上了基准tag的: 从1000 - 1003
        // scction 0 - 3
        let indexPath = NSIndexPath(forItem: 0, inSection: button.tag - baseTag)
        
        // 让collectionView滚动到对应位置
        // indexPath: 要显示的cell的indexPath
        // animated: 是否动画
        // scrollPosition: 滚动位置
//        print("滚动到section = \(indexPath.section)")
        collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Left)
        
        switchSelectedButton(button)
    }
    
    /// 记录当前选中高亮的按钮
    private var selectedButton: UIButton?
    
    /// 按钮的起始tag
    private let baseTag = 1000
    
    /**
    使按钮高亮
    - parameter button: 要高亮的按钮
    */
    private func switchSelectedButton(button: UIButton) {
        // 取消之前选中的
        selectedButton?.selected = false
        
        // 让点击的按钮选中
        button.selected = true
        
        // 将点击的按钮赋值给选中的按钮
        selectedButton = button
    }
    
    
    /// 设置collectioView
    private func setupCollectionView() {
        // 设置背景颜色
        collectionView.backgroundColor = UIColor(white: 0.85, alpha: 1)

        // 设置数据源
        collectionView.dataSource = self
        
        // 设置代理
        collectionView.delegate = self
        
        // 注册cell
        collectionView.registerClass(JFEmoticonCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
        
        // 设置滚动方向
//        collectionView.collectionViewLayout
    }

    // MARK: - 懒加载
    /// collectionView
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: JFCollectionViewFlowLayout())
    
    /// toolBar
    private lazy var toolBar = UIToolbar()
    
    /// 表情包模型
    /// 访问内存中的表情包模型数据
    private lazy var packages = JFEmoticonPackage.packages
}

// MARK: - 扩展 JFEmoticonViewController 实现 协议 UICollectionViewDataSource
extension JFEmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // 返回多少组(一个表情包一组)
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    // 返回cell的数量(每个表情包里面的表情数量不一样)
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 获取对应表情包里面的表情数量
        // packages[section]: 获取对应的表情包
        // packages[section].emoticons?.count 获取对应的表情包里面的表情数量
        return packages[section].emoticons?.count ?? 0
    }
    
    // 返回cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath) as! JFEmoticonCell
        
//        cell.backgroundColor = UIColor.randomColor()
        // 获取对应的表情模型
        let emoticon = packages[indexPath.section].emoticons?[indexPath.item]
        
        // 赋值给cell
        cell.emoticon = emoticon
        
        return cell
    }
    
    // 监听scrollView滚动,当停下来的时候判断显示的是哪个section
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 获取到正在显示的section -> indexPath
        // 获取到collectionView正在显示的cell的IndexPath
        if let indexPath = collectionView.indexPathsForVisibleItems().first {
            // 获取对应的section 0 - 3
            let section = indexPath.section
//            print("停止滚动 section: \(section)")
            
            // section 和按钮的位置是对应的
            // 获取toolBar上面的button
            // button.tag 是加上了基准tag的: 从1000 - 1003 baseTag = 1000
            // section 0 - 3
            let button = toolBar.viewWithTag(section + baseTag) as! UIButton
            
//            print("查找到的按钮的tag: \(button.tag)")
            // 让它选中
            switchSelectedButton(button)
        }
    }
    
    /*
        将点击的表情插入到textView里面
            1.获取textView
            2.需要知道点击哪个表情
    */
    
    // collectionView cell的点击事件
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 添加表情到textView
        // 获取到表情
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
//        print("cell 点击, 表情: \(emoticon)")
        
        textView?.insertEmoticon(emoticon)
        
        // 当点击最近里面的表情,发现点击的和添加到textView上面的不是同一个,原因是数据发生改变,显示没有变化
        // 1.刷新数据
//        collectionView.reloadSections(NSIndexSet(index: indexPath.section))
        
        // 2.当点击的是最近表情包得表情,不添加到最近表情包和排序
        
        if indexPath.section != 0 {
            // 添加 表情模型 到  最近表情包
            JFEmoticonPackage.addFavorate(emoticon)
        }
        
//        insertEmoticon(emoticon)
    }
    
//    /// 添加表情到textView
//    private func insertEmoticon(emoticon: JFEmoticon) {
//        guard let tv = textView else {
//            print("没有textView,无法添加表情")
//            return
//        }
//        
//        // 添加emoji表情
//        if let emoji = emoticon.emoji{
//            tv.insertText(emoji)
//        }
//        
//        // 添加图片表情
//        if let pngPath = emoticon.pngPath {
//            // 创建附件
//            let attachment = JFTextAttachment()
//            
//            // 创建 image
//            let image = UIImage(contentsOfFile: pngPath)
//            
//            // 将 image 添加到附件
//            attachment.image = image
//            
//            // 将表情图片的名称赋值
//            attachment.name = emoticon.chs
//            
//            // 获取font的高度
//            let height = tv.font?.lineHeight ?? 10
//            
//            // 设置附件大小
//            attachment.bounds = CGRect(x: 0, y: -(height * 0.25), width: height, height: height)
//            
//            // 创建属性文本
//            let attrString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
//            
//            // 发现在表情图片后面在添加表情会很小.原因是前面的这个表请缺少font属性
//            // 给属性文本(附件) 添加 font属性
//            attrString.addAttribute(NSFontAttributeName, value: tv.font!, range: NSRange(location: 0, length: 1))
//            
//            // 获取到已有的文本,将表情添加到已有文本里面
//            let oldAttrString = NSMutableAttributedString(attributedString: tv.attributedText)
//            
//            // 记录选中的范围
//            let oldSelectedRange = tv.selectedRange
//            
//            // range: 替换的范围
//            oldAttrString.replaceCharactersInRange(oldSelectedRange, withAttributedString: attrString)
//            
//            // 赋值给textView的 attributedText
//            tv.attributedText = oldAttrString
//            
//            // 设置光标位置,在表情后面
//            tv.selectedRange = NSRange(location: oldSelectedRange.location + 1, length: 0)
//        }
//    }
}

// MARK: - 自定义表情cell
class JFEmoticonCell: UICollectionViewCell {
    
    // MARK: - 属性
    /// 表情模型
    var emoticon: JFEmoticon? {
        didSet {
            // 设置内容
            // 设置图片
//            print("emoticon.png:\(emoticon?.pngPath)")
            if let pngPath = emoticon?.pngPath {
                emoticonButton.setImage(UIImage(contentsOfFile: pngPath), forState: UIControlState.Normal)
            } else {    // 防止cell复用
                emoticonButton.setImage(nil, forState: UIControlState.Normal)
            }
            
            // 显示emoji表情
            emoticonButton.setTitle(emoticon?.emoji, forState: UIControlState.Normal)
//            if let emoji = emoticon?.emoji {
//                emoticonButton.setTitle(emoji, forState: UIControlState.Normal)
//            } else {
//                emoticonButton.setTitle(nil, forState: UIControlState.Normal)
//            }
            
            // 判断是否是删除按钮模型
            if emoticon!.removeEmoticon {
                // 是删除按钮
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
            }
        }
    }
 
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        print("frame:\(frame)")
        
        prepareUI()
    }

    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(emoticonButton)
        
        // 设置frame
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        
        // 禁止按钮可以点击
        emoticonButton.userInteractionEnabled = false
        
        // 设置title大小
        emoticonButton.titleLabel?.font = UIFont.systemFontOfSize(32)
//        emoticonButton.backgroundColor = UIColor.magentaColor()
    }
    
    // MARK: - 懒加载
    /// 表情按钮
    private lazy var emoticonButton: UIButton = UIButton()
}

// MARK: - 继承流水布局
/// 在collectionView布局之前设置layout的参数
class JFCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // 重写 prepareLayout
    override func prepareLayout() {
        super.prepareLayout()
        // 布局所在的collectionView
//        print("collectionView:\(collectionView)")
        
        // item 宽度
        let width = collectionView!.frame.width / 7.0
        
        // item 高度
        let height = collectionView!.frame.height / 3.0
        
        // 设置layout 的 itemSize
        itemSize = CGSize(width: width, height: height)

        // 滚动方向
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        // 间距
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        // 取消弹簧效果
        collectionView?.bounces = false
        collectionView?.alwaysBounceHorizontal = false
        
        collectionView?.showsHorizontalScrollIndicator = false
        
        // 分页显示
        collectionView?.pagingEnabled = true
    }
}