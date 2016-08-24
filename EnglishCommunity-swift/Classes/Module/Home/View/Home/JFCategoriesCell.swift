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
    func categoriesCell(cell: UITableViewCell, didSelectItemAtIndexPath indexPath: NSIndexPath)
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
    private func prepareUI() {
        
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
        layout.minimumInteritemSpacing = 1.5
        layout.minimumLineSpacing = 1.5
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: SCREEN_WIDTH * 0.21, height: SCREEN_WIDTH * 0.19)
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(UINib(nibName: "JFCategoriesCellItem", bundle: nil), forCellWithReuseIdentifier: self.categoryIdentifier)
        return collectionView
    }()
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFCategoriesCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoCategories!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier(categoryIdentifier, forIndexPath: indexPath) as! JFCategoriesCellItem
        item.category = videoCategories![indexPath.item]
        return item
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.categoriesCell(self, didSelectItemAtIndexPath: indexPath)
    }
}