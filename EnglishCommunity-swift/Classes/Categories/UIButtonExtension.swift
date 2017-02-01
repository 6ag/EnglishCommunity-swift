//
//  UIButtonExtension.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 2017/2/1.
//  Copyright © 2017年 zhoujianfeng. All rights reserved.
//

import UIKit

extension UIButton {
    
    /// 设置圆形头像
    ///
    /// - Parameters:
    ///   - urlString: 图片url
    ///   - placeholderImage: 占位图
    func setBackgroundImage(urlString: String?, size: CGSize?, placeholderImage: UIImage? = UIImage(named: "default－portrait")) {
        
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                setBackgroundImage(placeholderImage, for: .normal)
                return
        }
        
        yy_setBackgroundImage(with: url, for: .normal, placeholder: placeholderImage, options: []) { [weak self] (image, _, _, _, _) in
            
            guard let image = image else {
                return
            }
            self?.setBackgroundImage(image.redrawOvalImage(size: size, bgColor: self?.superview?.backgroundColor ?? UIColor.white), for: .normal)
        }
    }
}
