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
    private let cellIdentifier = "photoCellIdentifier"
    
    /// 图片模型数组
    private var photoModels: [JFPhotoBrowserModel]
    
    /// 当前选中的图片下标
    private var selectedIndex: Int
    
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 滚动到对应的张数
        let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
        collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        prepareUI()
        
        // 设置页数  当前页 / 总页数
        pageLabel.text = "\(selectedIndex + 1) / \(photoModels.count)"
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.addSubview(bkgView)
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(saveButton)
        
        pageLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(20)
        }
        
        saveButton.snp_makeConstraints { (make) in
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
        let indexPath = collectionView.indexPathsForVisibleItems().first!
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JFPhotoBrowserCell
        
        if let image = cell.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(JFPhotoBrowserViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    /**
     保存图片后的回调
     */
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
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
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: space)
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(JFPhotoBrowserCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH + space, height: SCREEN_HEIGHT)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.bounces = false
        collectionView.pagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    /// 保存
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "photo_browser_download"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(JFPhotoBrowserViewController.save), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    /// 页码的label
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    /// 背景视图,用于修改alpha
    private lazy var bkgView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension JFPhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 返回cell的个数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! JFPhotoBrowserCell
        cell.backgroundColor = UIColor.clearColor()
        cell.photoModel = photoModels[indexPath.item]
        cell.cellDelegate = self
        return cell
    }
    
    // scrolView停止滚动,获取当前显示cell的indexPath
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 获取正在显示的cell
        let indexPath = collectionView.indexPathsForVisibleItems().first!
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
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    /**
     单击事件退出
     */
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     双击事件放大
     */
    func didDoubleTappedPhotoDetailView(scrollView: UIScrollView, touchPoint: CGPoint) -> Void {
        if scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + scrollView.contentOffset.x
            let scaleY = touchPoint.y + scrollView.contentOffset.y
            scrollView.zoomToRect(CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension JFPhotoBrowserViewController: UIViewControllerTransitioningDelegate {
    // 返回 控制 modal动画 对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 创建 控制 modal动画 对象
        return JFPhotoBrowserModalAnimation()
    }
    
    // 控制 dismiss动画 对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
        tempImageView.frame = thumbImageView.superview!.convertRect(thumbImageView.frame, toCoordinateSpace: view)
        
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
        let indexPath = collectionView.indexPathsForVisibleItems().first!
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! JFPhotoBrowserCell
        
        // 判断图片是否存在
        if cell.imageView.image == nil {
            return nil
        }
        
        // 获取正在显示的图片
        let image = cell.imageView.image!
        
        // 创建过渡视图
        let tempImageView = UIImageView(image: image)
        
        // 设置过渡视图
        tempImageView.contentMode = UIViewContentMode.ScaleAspectFill
        tempImageView.clipsToBounds = true
        
        // 设置frame
        // 转换坐标系
        let rect = cell.imageView.superview!.convertRect(cell.imageView.frame, toCoordinateSpace: view)
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
        let rect = thumbImageView!.superview!.convertRect(thumbImageView!.frame, toCoordinateSpace: view)
        
        return rect
    }
}