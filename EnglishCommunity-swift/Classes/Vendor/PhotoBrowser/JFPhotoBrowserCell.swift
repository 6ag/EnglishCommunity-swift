//
//  JFPhotoBrowserCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage
import SnapKit

class JFPhotoBrowserCell: UICollectionViewCell {
    
    // MARK: - 属性
    weak var cellDelegate: JFPhotoBrowserCellDelegate?
    
    /// 图片模型
    var photoModel: JFPhotoBrowserModel? {
        didSet {
            guard let imageURL = photoModel?.url else {
                return
            }
            
            // 将imageView图片设置为nil,防止cell重用
            imageView.image = nil
            resetProperties()
            
            indicator.startAnimating()
            imageView.yy_setImageWithURL(imageURL, placeholder: nil, options: YYWebImageOptions.AllowBackgroundTask) { (image, url, _, _, error) in
                self.indicator.stopAnimating()
                
                if let image = image {
                    self.layoutImageView(image)
                }
                
            }
            
        }
    }
    
    /// 清除属性,防止cell复用
    private func resetProperties() {
        imageView.transform = CGAffineTransformIdentity
        
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
    }
    
    /// 根据长短图,重新布局imageView
    private func layoutImageView(image: UIImage) {
        // 获取等比例缩放后的图片大小
        let size = image.equalScaleWithWidth(SCREEN_WIDTH)
        
        // 判断长短图
        if size.height < SCREEN_HEIGHT {
            // 短图, 居中显示
            
            let offestY = (SCREEN_HEIGHT - size.height) * 0.5
            
            // 不能通过frame来确定Y值,否则在放大的时候底部可会有看不到
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 设置scrollView.contentInset.top是可以滚动的
            scrollView.contentInset = UIEdgeInsets(top: offestY, left: 0, bottom: offestY, right: 0)
        } else {
            // 长图, 顶部显示
            imageView.frame = CGRect(origin: CGPointZero, size: size)
            
            // 设置滚动
            scrollView.contentSize = size
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
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        // 添加单击双击事件
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(didOneTappedPhotoDetailView(_:)))
        addGestureRecognizer(oneTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTappedPhotoDetailView(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        // 如果监听到双击事件，单击事件则不触发
        oneTap.requireGestureRecognizerToFail(doubleTap)
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(indicator)
        
        // 设置scrollView的缩放
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 0.5
        scrollView.delegate = self
        
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        indicator.snp_makeConstraints { (make) in
            make.center.equalTo(contentView)
        }
        
    }
    
    // MARK: - 各种手势
    /**
     图秀详情界面单击事件，隐藏除去图片外的所有UI
     */
    func didOneTappedPhotoDetailView(tap: UITapGestureRecognizer) {
        cellDelegate?.didOneTappedPhotoDetailView(scrollView)
    }
    
    /**
     图秀详情界面双击事件，缩放
     */
    func didDoubleTappedPhotoDetailView(tap: UITapGestureRecognizer) {
        let touchPoint = tap.locationInView(self)
        cellDelegate?.didDoubleTappedPhotoDetailView(scrollView, touchPoint: touchPoint)
    }
    
    // MARK: - 懒加载
    /// scrollView
    private lazy var scrollView = UIScrollView()
    
    /// imageView
    lazy var imageView: JFImageView = JFImageView()
    
    /// 下载图片提示
    private lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
}

protocol JFPhotoBrowserCellDelegate: NSObjectProtocol {
    
    // 获取一个view,在缩放的时候修改alpha
    func viewForTransparent() -> UIView
    
    // 通知控制器关闭
    func cellDismiss()
    
    // 单击事件
    func didOneTappedPhotoDetailView(scrollView: UIScrollView)
    
    // 双击事件
    func didDoubleTappedPhotoDetailView(scrollView: UIScrollView, touchPoint: CGPoint)
}

// MARK: - UIScrollViewDelegate
extension JFPhotoBrowserCell: UIScrollViewDelegate {
    
    /// 返回需要缩放的view,设置imageView.transform
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /*
     缩放后frame会改变.bounds不会改变
     */
    /// scrollView缩放完毕调用
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        // 往中间移动
        // Y偏移
        var offestY = (scrollView.bounds.height - imageView.frame.height) * 0.5
        
        // X偏移
        var offestX = (scrollView.bounds.width - imageView.frame.width) * 0.5
        
        // 当 offest 时,让 offest = 0,否则会托不动
        if offestY < 0 {
            offestY = 0
        }
        
        if offestX < 0 {
            offestX = 0
        }
        
        // 当缩放比例小于一定的值,就自动缩放回去
        if imageView.transform.a < 0.7 {
            
            // 缩放到缩略图的位置,在关闭控制器
            // 获取缩略图
            let thumbImage = photoModel!.imageView!
            
            // 计算缩放后的位置
            let rect = thumbImage.superview!.convertRect(thumbImage.frame, toCoordinateSpace: self)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                // 设置 imageView的bounds
                self.imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
                
                self.scrollView.contentOffset.x = -rect.origin.x
                self.scrollView.contentOffset.y = -rect.origin.y
                
                self.scrollView.contentInset = UIEdgeInsets(top: rect.origin.y, left: rect.origin.x, bottom: 0, right: 0)
                
                }, completion: { (_) -> Void in
                    self.cellDelegate?.cellDismiss()
            })
            
        } else {
            // 移到中间去
            UIView.animateWithDuration(0.25) { () -> Void in
                // 当缩放比例小于设置的最小缩放比例时,会动画到左上角,在调用 scrollViewDidEndZooming,不让系统缩放到比指定最小缩放比例还小的值
                // 设置scrollView的contentInset来居中图片
                scrollView.contentInset = UIEdgeInsets(top: offestY, left: offestX, bottom: offestY, right: offestX)
            }
        }
        
    }
    
    /// scrollView缩放时调用
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        // 修改控制器的背景
        // 通过代理获取需要设置alpha的view
        let view = cellDelegate?.viewForTransparent()
        
        // 根据缩放比例来设置view的alpha
        if imageView.transform.a < 1 {
            // 设置alpah
            view?.alpha = imageView.transform.a * 0.7 - 0.2
        } else {
            view?.alpha = 1
        }
    }
}