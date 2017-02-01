//
//  JFPhotoSelectorViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class JFPhotoSelectorViewController: UICollectionViewController, JFPhotoSelectorCellDelegate {
    
    // MRAK: - 属性
    /// 选择的图片
    var photos = [UIImage]()
    
    /// 最大照片张数
    fileprivate let maxPhotoCount = 9
    
    /// 重用标识
    fileprivate let reuseIdentifier = "selectPhotoCell"
    
    /// collectionView 的 布局
    fileprivate var layout = UICollectionViewFlowLayout()
    
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
        collectionView?.register(JFPhotoSelectorCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = UIColor.clear
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 当图片数量小于最大张数, cell的数量 = 照片的张数 + 1
        // 当图片数量等于最大张数, cell的数量 = 照片的张数
        return photos.count < maxPhotoCount ? photos.count + 1 : photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JFPhotoSelectorCell
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
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            print("摄像头不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.view.backgroundColor = COLOR_ALL_BG
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    /**
     从相册选择图片
     */
    func selectPhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            print("相册不可用")
            return
        }
        
        // 弹出系统的相册
        let picker = UIImagePickerController()
        picker.view.backgroundColor = COLOR_ALL_BG
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    /**
     点击了加号按钮
     */
    func photoSelectorCellAddPhoto(_ cell: JFPhotoSelectorCell) {
        
        // 点击的不是加号按钮则不处理
        if collectionView?.indexPath(for: cell)?.item < photos.count && photos.count == maxPhotoCount {
            return
        }
        
        selectPhoto()
    }
    
    /**
     删除图片
     */
    func photoSelectorCellRemovePhoto(_ cell: JFPhotoSelectorCell) {
        let indexPath = collectionView!.indexPath(for: cell)!
        photos.remove(at: indexPath.item)
        collectionView?.reloadData()
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension JFPhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let newImage = image.scaleImage()
        photos.append(newImage)
        collectionView?.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - cell点击时间代理
protocol JFPhotoSelectorCellDelegate: NSObjectProtocol {
    func photoSelectorCellAddPhoto(_ cell: JFPhotoSelectorCell)
    func photoSelectorCellRemovePhoto(_ cell: JFPhotoSelectorCell)
}

// MARK: - 自定义cell
class JFPhotoSelectorCell: UICollectionViewCell {
    
    // image 用来显示, 替换加号按钮的图片
    var image: UIImage? {
        didSet {
            addButton.setImage(image, for: UIControlState())
            addButton.setImage(image, for: UIControlState.highlighted)
            removeButton.isHidden = false
        }
    }
    
    /// 设置加号按钮的图片
    func setAddButton() {
        addButton.setImage(UIImage(named: "compose_pic_add"), for: UIControlState())
        addButton.setImage(UIImage(named: "compose_pic_add_highlighted"), for: UIControlState.highlighted)
        removeButton.isHidden = true
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
    fileprivate func prepareUI() {
        
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        
        addButton.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        removeButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(0)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
        
    }
    
    // MARK: - 懒加载
    /// 加号按钮
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "compose_pic_add"), for: UIControlState())
        button.setImage(UIImage(named: "compose_pic_add_highlighted"), for: UIControlState.highlighted)
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.addPhoto), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    /// 删除按钮
    fileprivate lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "compose_photo_close"), for: UIControlState())
        button.addTarget(self, action: #selector(JFPhotoSelectorCell.removePhoto), for: UIControlEvents.touchUpInside)
        return button
    }()
}
