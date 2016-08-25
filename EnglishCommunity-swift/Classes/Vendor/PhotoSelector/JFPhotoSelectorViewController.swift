//
//  JFPhotoSelectorViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFPhotoSelectorViewController: UICollectionViewController, JFPhotoSelectorCellDelegate {
    
    // MRAK: - 属性
    /// 选择的图片
    var photos = [UIImage]()
    
    /// 最大照片张数
    private let maxPhotoCount = 9
    
    /// 重用标识
    private let reuseIdentifier = "selectPhotoCell"
    
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
        collectionView?.registerClass(JFPhotoSelectorCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = UIColor.clearColor()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 当图片数量小于最大张数, cell的数量 = 照片的张数 + 1
        // 当图片数量等于最大张数, cell的数量 = 照片的张数
        return photos.count < maxPhotoCount ? photos.count + 1 : photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! JFPhotoSelectorCell
        cell.cellDelegate = self
        
        if indexPath.item < photos.count {
            // 当有图片的时候才设置图片
            cell.image = photos[indexPath.item]
        } else {
            // 设置图片防止cell复用
            cell.setAddButton()
        }
        
        return cell
    }
    
    /**
     拍照
     */
    func takePhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            print("摄像头不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.view.backgroundColor = COLOR_ALL_BG
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
    /**
     从相册选择图片
     */
    func selectPhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            print("相册不可用")
            return
        }
        
        // 弹出系统的相册
        let picker = UIImagePickerController()
        picker.view.backgroundColor = COLOR_ALL_BG
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    /**
     点击了加号按钮
     */
    func photoSelectorCellAddPhoto(cell: JFPhotoSelectorCell) {
        
        // 点击的不是加号按钮则不处理
        if collectionView?.indexPathForCell(cell)?.item < photos.count && photos.count == maxPhotoCount {
            return
        }
        
        selectPhoto()
    }
    
    /**
     删除图片
     */
    func photoSelectorCellRemovePhoto(cell: JFPhotoSelectorCell) {
        let indexPath = collectionView!.indexPathForCell(cell)!
        photos.removeAtIndex(indexPath.item)
        collectionView?.reloadData()
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension JFPhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newImage = image.scaleImage()
        photos.append(newImage)
        collectionView?.reloadData()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - cell点击时间代理
protocol JFPhotoSelectorCellDelegate: NSObjectProtocol {
    func photoSelectorCellAddPhoto(cell: JFPhotoSelectorCell)
    func photoSelectorCellRemovePhoto(cell: JFPhotoSelectorCell)
}

// MARK: - 自定义cell
class JFPhotoSelectorCell: UICollectionViewCell {
    
    // image 用来显示, 替换加号按钮的图片
    var image: UIImage? {
        didSet {
            addButton.setImage(image, forState: UIControlState.Normal)
            addButton.setImage(image, forState: UIControlState.Highlighted)
            removeButton.hidden = false
        }
    }
    
    /// 设置加号按钮的图片
    func setAddButton() {
        addButton.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        addButton.setImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
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
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        addButton.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        removeButton.snp_makeConstraints { (make) in
            make.top.right.equalTo(0)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
    }
    
    // MARK: - 懒加载
    /// 加号按钮
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
        button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.addPhoto), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    /// 删除按钮
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "compose_photo_close"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.removePhoto), forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
}
