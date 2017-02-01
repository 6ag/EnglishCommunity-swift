//
//  JFCategoriesCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

protocol JFCategoriesCellDelegate: NSObjectProtocol {
    func categoriesCell(_ cell: UITableViewCell, didSelectItemAtIndexPath indexPath: IndexPath)
}

class JFCategoriesCell: UITableViewCell {

    // MARK: - 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let categoryIdentifier = "JFCategoriesCellItem"
    
    weak var delegate: JFCategoriesCellDelegate?
    
    /// 所以分类模型数组
    var videoCategories: [JFVideoCategory]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    // MARK: - 懒加载
    /// collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1.5
        layout.minimumLineSpacing = 1.5
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: SCREEN_WIDTH * 0.21, height: SCREEN_WIDTH * 0.19)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "JFCategoriesCellItem", bundle: nil), forCellWithReuseIdentifier: self.categoryIdentifier)
        return collectionView
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFCategoriesCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoCategories!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: categoryIdentifier, for: indexPath) as! JFCategoriesCellItem
        item.category = videoCategories![indexPath.item]
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoriesCell(self, didSelectItemAtIndexPath: indexPath)
    }
}
