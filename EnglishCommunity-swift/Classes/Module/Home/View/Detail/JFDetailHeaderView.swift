
//
//  JFDetailHeaderView.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/18.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFDetailHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var videoInfo: JFVideoInfo? {
        didSet {
            guard let videoInfo = videoInfo else {
                return
            }
            titleLabel.text = videoInfo.title
            teacherLabel.text = videoInfo.teacherName
            joinCountLabel.text = "\(videoInfo.view) 人学过"
            videoCountLabel.text = "共\(videoInfo.videoCount)节"
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        backgroundColor = UIColor.whiteColor()
        addSubview(titleLabel)
        addSubview(teacherIconImageView)
        addSubview(teacherLabel)
        addSubview(joinCountLabel)
        addSubview(videoCountLabel)
        
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(13)
        }
        
        teacherIconImageView.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        
        teacherLabel.snp_makeConstraints { (make) in
            make.left.equalTo(teacherIconImageView.snp_right).offset(7)
            make.centerY.equalTo(teacherIconImageView)
        }
        
        joinCountLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(teacherLabel)
        }
        
        videoCountLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(teacherLabel)
            make.right.equalTo(-16)
        }
    }
    
    // MARK: - 懒加载
    /// 课程标题
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.colorWithHexString("323733")
        return label
    }()
    
    /// 讲师图标
    lazy var teacherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "category_teacher_icon")
        return imageView
    }()
    
    /// 讲师
    lazy var teacherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.colorWithHexString("B8C2BA")
        return label
    }()
    
    /// 收藏数量
    lazy var joinCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.colorWithHexString("B8C2BA")
        return label
    }()

    /// 视频数量
    lazy var videoCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.colorWithHexString("B8C2BA")
        return label
    }()

}
