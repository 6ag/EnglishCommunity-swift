//
//  JFHomeCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFHomeCellDelegate: NSObjectProtocol {
    func homeCell(_ cell: UITableViewCell, didSelectItemAtIndexPath indexPath: IndexPath)
}

class JFHomeCell: UITableViewCell {

    // MARK: - 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let categoryIdentifier = "JFHomeCellItem"
    weak var delegate: JFHomeCellDelegate?
    
    /// 所以分类模型数组
    var videoCategory: JFVideoCategory? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        contentView.backgroundColor = COLOR_ALL_BG
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        // 离屏渲染 - 异步绘制
        layer.drawsAsynchronously = true
        
        // 栅格化 - 异步绘制之后，会生成一张独立的图像，cell在屏幕上滚动的时候，本质滚动的是这张图片
        layer.shouldRasterize = true
        
        // 使用栅格化，需要指定分辨率
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    // MARK: - 懒加载
    /// collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = LIST_ITEM_PADDING
        layout.minimumLineSpacing = LIST_ITEM_PADDING
        layout.sectionInset = UIEdgeInsets(top: 0, left: LIST_ITEM_PADDING, bottom: 0, right: LIST_ITEM_PADDING)
        layout.itemSize = CGSize(width: LIST_ITEM_WIDTH, height: LIST_ITEM_HEIGHT)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = COLOR_ALL_BG
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "JFHomeCellItem", bundle: nil), forCellWithReuseIdentifier: self.categoryIdentifier)
        return collectionView
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFHomeCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoCategory?.videoInfos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: categoryIdentifier, for: indexPath) as! JFHomeCellItem
        item.videoInfo = videoCategory!.videoInfos![indexPath.item]
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.homeCell(self, didSelectItemAtIndexPath: indexPath)
    }
}
