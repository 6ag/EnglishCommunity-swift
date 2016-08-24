//
//  JFGrammarListCell.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import SnapKit

class JFGrammarListCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var grammar: JFGrammar? {
        didSet {
            textLabel?.text = grammar?.title
        }
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        contentView.addSubview(lineView)
        lineView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
    }
    
    /**
     修改cell点击后高亮颜色
     */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            contentView.backgroundColor = COLOR_ALL_CELL_HIGH
        } else {
            contentView.backgroundColor = COLOR_ALL_CELL_NORMAL
        }
    }
    
    /// 分割线
    private lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = COLOR_ALL_CELL_SEPARATOR
        return lineView
    }()
}
