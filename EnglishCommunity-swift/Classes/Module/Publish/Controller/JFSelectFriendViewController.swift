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
    var callback: ((relationUsers: [JFRelationUser]?) -> ())?
    
    var relationUsers = [JFRelationUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        loadData()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        title = "选择@好友"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
        prepareNavigationBar()
    }
    
    /**
     准备导航栏
     */
    private func prepareNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.leftItem("top_navigation_back_normal", highlightedImage: "top_navigation_back_normal", target: self, action: #selector(didTappedBackBarButton(_:)))
    }
    
    /**
     返回
     */
    @objc private func didTappedBackBarButton(barButtonItem: UIBarButtonItem) {
        
        var relationUsers = [JFRelationUser]()
        for relationUser in self.relationUsers {
            if relationUser.selected {
                relationUsers.append(relationUser)
            }
        }
        
        /// 回调选中的用户数据
        if let callback = callback {
            callback(relationUsers: relationUsers)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     加载数据
     */
    private func loadData() {
        
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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerClass(JFSelectFriendCell.classForCoder(), forCellReuseIdentifier: self.selectFriendIdentifier)
        return tableView
    }()
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSelectFriendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(selectFriendIdentifier, forIndexPath: indexPath) as! JFSelectFriendCell
        cell.relationUser = relationUsers[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! JFSelectFriendCell
        cell.selectorButton.selected = !cell.selectorButton.selected
        relationUsers[indexPath.row].selected = cell.selectorButton.selected
    }
    
}