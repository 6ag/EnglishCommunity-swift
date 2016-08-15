//
//  JFImageView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFImageView: UIImageView {

    override var transform: CGAffineTransform {
        didSet {
            // 当设置的缩放比例小于指定的最小缩放比例时.重新设置
            if transform.a < 0.5 {
                transform = CGAffineTransformMakeScale(0.5, 0.5)
            }
        }
    }

}
