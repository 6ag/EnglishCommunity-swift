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
    func homeCell(cell: UITableViewCell, didSelectItemAtIndexPath indexPath: NSIndexPath)
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
    private func prepareUI() {
        
        contentView.backgroundColor = COLOR_ALL_BG
        contentView.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - 懒加载
    /// collectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = LIST_ITEM_PADDING
        layout.minimumLineSpacing = LIST_ITEM_PADDING
        layout.sectionInset = UIEdgeInsets(top: 0, left: LIST_ITEM_PADDING, bottom: 0, right: LIST_ITEM_PADDING)
        layout.itemSize = CGSize(width: LIST_ITEM_WIDTH, height: LIST_ITEM_HEIGHT)
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.backgroundColor = COLOR_ALL_BG
        collectionView.scrollEnabled = false
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(UINib(nibName: "JFHomeCellItem", bundle: nil), forCellWithReuseIdentifier: self.categoryIdentifier)
        return collectionView
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFHomeCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoCategory?.videoInfos?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier(categoryIdentifier, forIndexPath: indexPath) as! JFHomeCellItem
        item.videoInfo = videoCategory!.videoInfos![indexPath.item]
        return item
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.homeCell(self, didSelectItemAtIndexPath: indexPath)
    }
}