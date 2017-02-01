//
//  JFProfileCell.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/5.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFProfileCell: UITableViewCell {

    // MARK: - 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 是否显示分割线
    var showLineView: Bool = false {
        didSet {
            settingLineView.isHidden = !showLineView
        }
    }
    
    /// cell模型
    var cellModel: JFProfileCellModel? {
        didSet {
            
            guard let cellModel = cellModel else {
                return
            }
            
            // 左边数据
            textLabel?.text = cellModel.title
            detailTextLabel?.text = cellModel.subTitle
            
            if cellModel.icon != nil {
                imageView?.image = UIImage(named: cellModel.icon!)
            } else {
                imageView?.image = nil
            }
            
            // 选中状态
            selectionStyle = cellModel.isKind(of: JFProfileCellArrowModel.self) ? .default : .none
            
            // 根据cell类型设置不同UI
            if cellModel.isKind(of: JFProfileCellArrowModel.self) {
                
                // 箭头
                let settingCellArrow = cellModel as! JFProfileCellArrowModel
                settingRightLabel.text = settingCellArrow.text
                accessoryView = rightView
                
            } else if cellModel.isKind(of: JFProfileCellSwitchModel.self) {
                
                // 开关
                let settingCellSwitch = cellModel as! JFProfileCellSwitchModel
                settingSwitchView.isOn = settingCellSwitch.on
                accessoryView = settingSwitchView
                
            } else if cellModel.isKind(of: JFProfileCellLabelModel.self) {
                
                // 文字
                let settingCellLabel = cellModel as! JFProfileCellLabelModel
                settingRightLabel.text = settingCellLabel.text
                accessoryView = settingRightLabel
                
            }
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineX = textLabel!.frame.origin.x
        let lineH: CGFloat = 0.5
        let lineY = frame.size.height - lineH
        let lineW = frame.size.width - lineX
        settingLineView.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        selectionStyle = .none
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        textLabel?.textColor = UIColor.colorWithHexString("444444")
        textLabel?.backgroundColor = UIColor.clear
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        detailTextLabel?.textColor = UIColor.black
        
        contentView.addSubview(settingLineView)
    }
    
    /**
     开关切换事件，修改本地偏好设置
     */
    @objc fileprivate func didChangedSwitch(_ settingSwitch: UISwitch) {
        let settingCellSwitch = cellModel as! JFProfileCellSwitchModel
        settingCellSwitch.on = settingSwitch.isOn
    }
    
    // MARK: - 懒加载
    /// 箭头旁的文字
    lazy var settingRightLabel: UILabel = {
        let settingRightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        settingRightLabel.textColor = UIColor.gray
        settingRightLabel.textAlignment = .right
        settingRightLabel.font = UIFont.systemFont(ofSize: 12)
        return settingRightLabel
    }()
    
    /// 箭头
    lazy var settingArrowView: UIImageView = {
        let settingArrowView = UIImageView(image: UIImage(named: "setting_arrow_icon"))
        return settingArrowView
    }()
    
    /// 开关
    lazy var settingSwitchView: UISwitch = {
        let settingSwitchView = UISwitch()
        settingSwitchView.addTarget(self, action: #selector(didChangedSwitch(_:)), for: .valueChanged)
        return settingSwitchView
    }()
    
    /// 分割线
    lazy var settingLineView: UIView = {
        let settingLineView = UIView()
        settingLineView.backgroundColor = UIColor.black
        settingLineView.alpha = 0.1
        return settingLineView
    }()
    
    /// 箭头和文字结合
    lazy var rightView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 20))
        view.backgroundColor = UIColor.clear
        view.addSubview(self.settingArrowView)
        view.addSubview(self.settingRightLabel)
        self.settingArrowView.frame = CGRect(x: 170, y: 2.5, width: 15, height: 15)
        self.settingRightLabel.frame = CGRect(x: 0, y: 0, width: 165, height: 20)
        return view
    }()

}
