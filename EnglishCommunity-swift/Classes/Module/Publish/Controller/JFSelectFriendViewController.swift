//
//  JFSelectFriendViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/16.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import YYWebImage

class JFSelectFriendViewController: UIViewController {
    
    let selectFriendIdentifier = "selectFriendIdentifier"
    
    /// 返回时回调选中的用户数据
    var callback: ((_ relationUsers: [JFRelationUser]?) -> ())?
    
    var relationUsers = [JFRelationUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        loadData()
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        title = "选择@好友"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
        prepareNavigationBar()
    }
    
    /**
     准备导航栏
     */
    fileprivate func prepareNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.leftItem("top_navigation_back_normal", highlightedImage: "top_navigation_back_normal", target: self, action: #selector(didTappedBackBarButton(_:)))
    }
    
    /**
     返回
     */
    @objc fileprivate func didTappedBackBarButton(_ barButtonItem: UIBarButtonItem) {
        
        var relationUsers = [JFRelationUser]()
        for relationUser in self.relationUsers {
            if relationUser.selected {
                relationUsers.append(relationUser)
            }
        }
        
        /// 回调选中的用户数据
        if let callback = callback {
            callback(relationUsers)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    /**
     加载数据
     */
    fileprivate func loadData() {
        
        JFRelationUser.getFriendList(1) { (relationUsers) in
            guard let relationUsers = relationUsers else {
                return
            }
            
            self.relationUsers = relationUsers
            self.tableView.reloadData()
        }
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.register(JFSelectFriendCell.classForCoder(), forCellReuseIdentifier: self.selectFriendIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSelectFriendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: selectFriendIdentifier, for: indexPath) as! JFSelectFriendCell
        cell.relationUser = relationUsers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! JFSelectFriendCell
        cell.selectorButton.isSelected = !cell.selectorButton.isSelected
        relationUsers[indexPath.row].selected = cell.selectorButton.isSelected
    }
    
}
