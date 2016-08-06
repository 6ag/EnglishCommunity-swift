//
//  JFCategoryViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/5.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFCategoryViewController: UIViewController {
    
    var page: Int = 0
    
    var videoInfos = [JFVideoInfo]()
    
    let categoryIdentifier = "JFCategoryItem"
    
    var category: JFVideoCategory? {
        didSet {
            title = category!.name!
            pullDownRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        collectionView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        collectionView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(collectionView)
    }
    
    /**
     下拉刷新
     */
    @objc private func pullDownRefresh() {
        page = 1
        updateData(category!.id, page: page, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData(category!.id, page: page, method: 1)
    }
    
    /**
     更新数据
     
     - parameter category_id: 分类id
     */
    private func updateData(category_id: Int, page: Int, method: Int) {
        
        JFVideoInfo.loadVideoInfoList(page, count: 10, category_id: category_id, recommend: 0) { (videoInfos) in
            
            self.collectionView.mj_header.endRefreshing()
            self.collectionView.mj_footer.endRefreshing()
            
            guard let videoInfos = videoInfos else {
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            // 下拉
            if (method == 0) {
                self.videoInfos = videoInfos
            } else {
                self.videoInfos += videoInfos
            }
            
            self.collectionView.reloadData()
            
        }
    }

    // MARK: - 懒加载
    /// collectionView
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = LIST_ITEM_PADDING
        layout.minimumLineSpacing = LIST_ITEM_PADDING
        layout.sectionInset = UIEdgeInsets(top: 10, left: LIST_ITEM_PADDING, bottom: 0, right: LIST_ITEM_PADDING)
        layout.itemSize = CGSize(width: LIST_ITEM_WIDTH, height: LIST_ITEM_HEIGHT)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(UINib(nibName: "JFHomeCellItem", bundle: nil), forCellWithReuseIdentifier: self.categoryIdentifier)
        return collectionView
    }()
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoInfos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier(categoryIdentifier, forIndexPath: indexPath) as! JFHomeCellItem
        item.videoInfo = videoInfos[indexPath.item]
        return item
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let playerVc = JFPlayerViewController()
        playerVc.videoInfo = videoInfos[indexPath.item]
        navigationController?.pushViewController(playerVc, animated: true)
    }
}
