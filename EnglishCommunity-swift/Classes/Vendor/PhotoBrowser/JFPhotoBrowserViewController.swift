//
//  JFPhotoBrowserViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFPhotoBrowserViewController: UIViewController {
    
    // MARK: - 属性
    /// 重用标识
    fileprivate let cellIdentifier = "photoCellIdentifier"
    
    /// 图片模型数组
    fileprivate var photoModels: [JFPhotoBrowserModel]
    
    /// 当前选中的图片下标
    fileprivate var selectedIndex: Int
    
    // MARK: - 构造函数
    init(models: [JFPhotoBrowserModel], selectedIndex: Int) {
        self.photoModels = models
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 显示点击对应的大图
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 滚动到对应的张数
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        prepareUI()
        
        // 设置页数  当前页 / 总页数
        pageLabel.text = "\(selectedIndex + 1) / \(photoModels.count)"
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        view.addSubview(bkgView)
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(saveButton)
        
        pageLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(20)
        }
        
        saveButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8)
            make.bottom.equalTo(-8)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
    }
    
    // MARK: - 按钮点击事件
    /**
     保存图片
     */
    func save() {
        
        // 获取正在显示的cell
        let indexPath = collectionView.indexPathsForVisibleItems.first!
        let cell = collectionView.cellForItem(at: indexPath) as! JFPhotoBrowserCell
        
        if let image = cell.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(JFPhotoBrowserViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    /**
     保存图片后的回调
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            JFProgressHUD.showInfoWithStatus("保存失败")
            return
        }
        
        JFProgressHUD.showSuccessWithStatus("保存成功")
        
    }
    
    // MARK: - 懒加载
    /// collectionView
    lazy var collectionView: UICollectionView = {
        
        let space: CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.view.bounds.size
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: space)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(JFPhotoBrowserCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH + space, height: SCREEN_HEIGHT)
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    /// 保存
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "photo_browser_download"), for: UIControlState())
        button.addTarget(self, action: #selector(JFPhotoBrowserViewController.save), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    /// 页码的label
    fileprivate lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    /// 背景视图,用于修改alpha
    fileprivate lazy var bkgView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFPhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 返回cell的个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! JFPhotoBrowserCell
        cell.backgroundColor = UIColor.clear
        cell.photoModel = photoModels[indexPath.item]
        cell.cellDelegate = self
        return cell
    }
    
    // scrolView停止滚动,获取当前显示cell的indexPath
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 获取正在显示的cell
        let indexPath = collectionView.indexPathsForVisibleItems.first!
        selectedIndex = indexPath.item
        pageLabel.text = "\(selectedIndex + 1) / \(photoModels.count)"
    }
    
}

// MARK: - JFPhotoBrowserCellDelegate
extension JFPhotoBrowserViewController: JFPhotoBrowserCellDelegate {
    
    /**
     返回需要设置alpha的view
     
     - returns: 需要改变透明度的背景视图
     */
    func viewForTransparent() -> UIView {
        return bkgView
    }
    
    /**
     缩放到一定比例关闭控制器
     */
    func cellDismiss() {
        // 关闭是不需要动画
        dismiss(animated: false, completion: nil)
    }
    
    /**
     单击事件退出
     */
    func didOneTappedPhotoDetailView(_ scrollView: UIScrollView) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     双击事件放大
     */
    func didDoubleTappedPhotoDetailView(_ scrollView: UIScrollView, touchPoint: CGPoint) -> Void {
        if scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + scrollView.contentOffset.x
            let scaleY = touchPoint.y + scrollView.contentOffset.y
            scrollView.zoom(to: CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension JFPhotoBrowserViewController: UIViewControllerTransitioningDelegate {
    // 返回 控制 modal动画 对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 创建 控制 modal动画 对象
        return JFPhotoBrowserModalAnimation()
    }
    
    // 控制 dismiss动画 对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return JFPhotoBrowserDismissAnimation()
    }
}

// MARK: - 转场动画
extension JFPhotoBrowserViewController {
    
    // MARK: - modal动画相关
    /**
     返回modal出来时需要的过渡视图
     
     - returns: modal出来时需要的过渡视图
     */
    func modalTempImageView() -> UIImageView {
        
        // 缩略图的view
        let thumbImageView = photoModels[selectedIndex].imageView!
        
        // 创建过渡视图
        let tempImageView = UIImageView(image: thumbImageView.image)
        tempImageView.contentMode = thumbImageView.contentMode
        tempImageView.clipsToBounds = true
        
        // thumbImageView.superview!: 转换前的坐标系 rect: 需要转换的frame toCoordinateSpace: 转换后的坐标系
        tempImageView.frame = thumbImageView.superview!.convert(thumbImageView.frame, to: view)
        
        return tempImageView
    }
    
    /**
     返回 modal动画时放大的frame
     
     - returns: modal动画时放大的frame
     */
    func modalTargetFrame() -> CGRect? {
        // 获取到对应的缩略图
        let thumbImageView = photoModels[selectedIndex].imageView!
        
        if thumbImageView.image == nil {
            return nil
        }
        
        // 获取缩略图
        let thumbImage = thumbImageView.image!
        
        // 宽度固定 等比缩放尺寸
        let newSize = thumbImage.equalScaleWithWidth(SCREEN_WIDTH)
        
        // 判断长短图
        var offestY: CGFloat = 0
        if newSize.height < SCREEN_HEIGHT {
            offestY = (SCREEN_HEIGHT - newSize.height) * 0.5
        }
        
        return CGRect(x: 0, y: offestY, width: newSize.width, height: newSize.height)
    }
    
    // MARK: - dismiss动画相关
    /**
     返回dismiss时的过渡视图
     
     - returns: dismiss时的过渡视图
     */
    func dismissTempImageView() -> UIImageView? {
        // 获取正在显示的cell
        let indexPath = collectionView.indexPathsForVisibleItems.first!
        let cell = collectionView.cellForItem(at: indexPath) as! JFPhotoBrowserCell
        
        // 判断图片是否存在
        if cell.imageView.image == nil {
            return nil
        }
        
        // 获取正在显示的图片
        let image = cell.imageView.image!
        
        // 创建过渡视图
        let tempImageView = UIImageView(image: image)
        
        // 设置过渡视图
        tempImageView.contentMode = UIViewContentMode.scaleAspectFill
        tempImageView.clipsToBounds = true
        
        // 设置frame
        // 转换坐标系
        let rect = cell.imageView.superview!.convert(cell.imageView.frame, to: view)
        tempImageView.frame = rect
        
        return tempImageView
    }
    
    /**
     返回缩小后的fram
     - returns: 缩小后的fram
     */
    func dismissTargetFrame() -> CGRect {
        
        let thumbImageView = photoModels[selectedIndex].imageView
        
        // 坐标系转换
        let rect = thumbImageView!.superview!.convert(thumbImageView!.frame, to: view)
        
        return rect
    }
}
