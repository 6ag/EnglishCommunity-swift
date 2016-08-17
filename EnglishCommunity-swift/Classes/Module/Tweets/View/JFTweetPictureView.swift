//
//  JFTweetsPictureView.swift
//  GZWeibo05
//
//  Created by zhangping on 15/11/1.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit
import YYWebImage

let JFPictureViewCellSelectedPictureNotification = "JFPictureViewCellSelectedPictureNotification"
let JFPictureViewCellSelectedPictureModelKey = "JFPictureViewCellSelectedPictureModelKey"
let JFPictureViewCellSelectedPictureIndexKey = "JFPictureViewCellSelectedPictureIndexKey"

class JFTweetPictureView: UICollectionView {
    
    private let tweetPictureViewIdentifier = "tweetPictureViewIdentifier"
    
    /// 布局
    private var layout = UICollectionViewFlowLayout()
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        
        backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        scrollEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerClass(JFTweetPictureViewCell.self, forCellWithReuseIdentifier: tweetPictureViewIdentifier)
    }
    
    /// 微博模型
    var images: [JFTweetImage]? {
        didSet {
            reloadData()
        }
    }
    
    /**
     计算配图区域尺寸
     
     - parameter itemWidth:  item宽度
     - parameter itemHeight: item高度
     - parameter margin:     item直接的间距
     
     - returns: 配图区域尺寸
     */
    func calculateViewSize(itemWidth: CGFloat, itemHeight: CGFloat, margin: CGFloat) -> CGSize {
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // 列数
        let column = 3
        
        // 根据模型的图片数量来计算尺寸
        let count = images?.count ?? 0
        
        // 无图
        if count == 0 {
            return CGSizeZero
        }
        
        // 单图
        if count == 1 {
            let urlString = images![0].thumb!
            let cacheImage = YYImageCache.sharedCache().getImageForKey(urlString)
            
            var size = CGSize(width: 150, height: 120)
            if let image = cacheImage {
                size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
            }
            
            layout.itemSize = size
            return size
        }
        
        layout.minimumInteritemSpacing = margin - 1
        layout.minimumLineSpacing = margin - 1
        
        // 2图
        if count == 2 {
            let width = 2 * itemWidth + margin
            return CGSize(width: width, height: itemWidth)
        }
        
        // 4图
        if count == 4 {
            let width = 2 * itemWidth + margin
            return CGSize(width: width, height: width)
        }
        
        // 剩下 3, 5, 6, 7, 8, 9图
        // 计算行数: 公式: 行数 = (图片数量 + 列数 -1) / 列数
        let row = (count + column - 1) / column
        
        // 宽度公式: 宽度 = (列数 * item的宽度) + (列数 - 1) * 间距
        let widht = (CGFloat(column) * itemWidth) + (CGFloat(column) - 1) * margin
        
        // 高度公式: 高度 = (行数 * item的高度) + (行数 - 1) * 间距
        let height = (CGFloat(row) * itemHeight) + (CGFloat(row) - 1) * margin
        
        return CGSize(width: widht, height: height)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFTweetPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tweetPictureViewIdentifier, forIndexPath: indexPath) as! JFTweetPictureViewCell
        cell.image = images![indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var models = [JFPhotoBrowserModel]()
        let count = images?.count ?? 0
        for i in 0..<count {
            let model = JFPhotoBrowserModel()
            
            let url = NSURL(string: (images?[i].href)!)
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) as! JFTweetPictureViewCell
            
            model.url = url
            model.imageView = cell.iconView
            models.append(model)
        }
        
        let userInfo: [String: AnyObject] = [
            JFPictureViewCellSelectedPictureModelKey : models,
            JFPictureViewCellSelectedPictureIndexKey : indexPath.item
        ]
        
        // 点击图片发出通知
        NSNotificationCenter.defaultCenter().postNotificationName(JFPictureViewCellSelectedPictureNotification, object: self, userInfo: userInfo)
        
    }
    
}

/// 自定义配图cell
class JFTweetPictureViewCell: UICollectionViewCell {
    
    // MARK: - 属性
    var image: JFTweetImage? {
        didSet {
            iconView.yy_setImageWithURL(NSURL(string: image!.thumb!), options: YYWebImageOptions.AllowBackgroundTask)
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
    private func prepareUI() {
        
        contentView.addSubview(iconView)
        iconView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - 懒加载
    /// 图片
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}