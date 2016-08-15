//
//  JFPhotoSelectorViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class JFPhotoSelectorViewController: UICollectionViewController, JFPhotoSelectorCellDelegate {
    
    // MRAK: - 属性
    /// 选择的图片
    var photos = [UIImage]()
    
    /// 记录点击的cell indexPath
    var currentIndexPath: NSIndexPath?
    
    /// 最大照片张数
    private let maxPhotoCount = 9
    
    /// collectionView 的 布局
    private var layout = UICollectionViewFlowLayout()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(collectionViewLayout: layout)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCollectionView()
    }
    
    /// 准备CollectionView
    func prepareCollectionView() {
        // 注册cell
        collectionView?.registerClass(JFPhotoSelectorCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView?.backgroundColor = UIColor.clearColor()
        
        // 设置itemSize
        layout.itemSize = CGSize(width: 80, height: 80)
        
        // layout设置section间距
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 当图片数量小于最大张数, cell的数量 = 照片的张数 + 1
        // 当图片数量等于最大张数, cell的数量 = 照片的张数
        return photos.count < maxPhotoCount ? photos.count + 1 : photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! JFPhotoSelectorCell
        
        cell.backgroundColor = UIColor.brownColor()
        
        cell.cellDelegate = self
        
        /*
            照片的数量   cell的数量     indexPath
                0           1           0
                1           2           0,1
                2,          3           0,1,2
        */
        
        // 当有图片的时候才设置图片
        if indexPath.item < photos.count {
            cell.image = photos[indexPath.item]
        } else {    // 设置图片防止cell复用
            cell.setAddButton()
        }
        
        return cell
    }
    
    /// 添加图片
    func photoSelectorCellAddPhoto(cell: JFPhotoSelectorCell) {
        // 判断相册是否可用
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            print("相册不可用")
            
            return
        }
        
        // 弹出系统的相册
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        // 记录当前点击的cell的indexPath
        currentIndexPath = collectionView?.indexPathForCell(cell)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    /// 删除图片
    func photoSelectorCellRemovePhoto(cell: JFPhotoSelectorCell) {
        // 点击的是哪个cell的删除按钮
        let indexPath = collectionView!.indexPathForCell(cell)!
        
        // 删除photos对应的图片
        photos.removeAtIndex(indexPath.item)
        
        // 刷新collectionView,某一行
        
        // deleteItemsAtIndexPaths cell需要少一个
        if photos.count < 5 {
            collectionView?.deleteItemsAtIndexPaths([indexPath])
        } else {
            collectionView?.reloadData()
        }

    }
}

extension JFPhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 选择照片时的代理方法
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("image:\(image)")
        
        let newImage = image.scaleImage()
        print("newImage:\(newImage)")
        
        // 当图片比较大的时候将它图片缩小
        
        // 将选择的照片添加到数组,让collectionView去显示
        // 如果点击的是图片,就是替换图片,如果点击的是加号按钮,添加图片
        
        if currentIndexPath?.item < photos.count {
            // 点击的是图片,替换图片
            photos[currentIndexPath!.item] = newImage
        } else {
            // 点击的是加号按钮
            photos.append(newImage)
        }
        
        // 刷新数据
        collectionView?.reloadData()
        
        // 关闭系统的相册
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - cell点击时间代理
@objc protocol JFPhotoSelectorCellDelegate: NSObjectProtocol {
    
    // 点击加号代理方法
    func photoSelectorCellAddPhoto(cell: JFPhotoSelectorCell)
    
    // 点击删除代理方法
    func photoSelectorCellRemovePhoto(cell: JFPhotoSelectorCell)
    
    // 可选的方法 协议需要加 @objc
    optional
    func test()
}

// MARK: - 自定义cell
class JFPhotoSelectorCell: UICollectionViewCell {
    
    // image 用来显示, 替换加号按钮的图片
    var image: UIImage? {
        didSet {
            addButton.setImage(image, forState: UIControlState.Normal)
            addButton.setImage(image, forState: UIControlState.Highlighted)
            
            // 显示删除按钮
            removeButton.hidden = false
        }
    }
    
    /// 设置加号按钮的图片
    func setAddButton() {
        // 设置按钮图片
        addButton.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        addButton.setImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
        
        // 隐藏删除按钮
        removeButton.hidden = true
    }
    
    // MARK: - 属性
    weak var cellDelegate: JFPhotoSelectorCellDelegate?
    
    // MARK: - 构造函数
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    // MARK: - 按钮点击事件
    func addPhoto() {
        cellDelegate?.photoSelectorCellAddPhoto(self)
    }
    
    func removePhoto() {
        cellDelegate?.photoSelectorCellRemovePhoto(self)
        
//        cellDelegate?.test?()
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["ab": addButton, "rb": removeButton]
        // 添加约束
        // 加号按钮
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[ab]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[ab]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // 删除按钮
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[rb]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[rb]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    // MARK: - 懒加载
    /// 加号按钮
    private lazy var addButton: UIButton = {
        let button = UIButton()
        
        // 设置按钮图片
        button.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
        
        // 设置按钮图片的显示模式
        button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        // 添加点击事件
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.addPhoto), forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    /// 删除按钮
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(named: "compose_photo_close"), forState: UIControlState.Normal)
        
        // 添加点击事件
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.removePhoto), forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
}
