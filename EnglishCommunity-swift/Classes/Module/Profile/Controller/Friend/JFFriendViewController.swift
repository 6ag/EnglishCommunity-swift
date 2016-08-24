//
//  JFFriendViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFFriendViewController: UITableViewController {
    
    var relationUsers = [JFRelationUser]()
    let friendCellIdentifier = "friendCellIdentifier"
    
    // 关系 0:粉丝 1:关注
    var relation = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = segmentedControl
        tableView.separatorStyle = .None
        tableView.rowHeight = 60
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerClass(JFFriendCell.classForCoder(), forCellReuseIdentifier: friendCellIdentifier)
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(loadFriendList))
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     加载数据
     */
    @objc private func loadFriendList() {
        
        JFRelationUser.getFriendList(relation) { (relationUsers) in
            
            self.tableView.mj_header.endRefreshing()
            guard let relationUsers = relationUsers else {
                self.relationUsers.removeAll()
                JFProgressHUD.showInfoWithStatus("暂时没有数据")
                self.tableView.reloadData()
                return
            }
            
            self.relationUsers = relationUsers
            self.tableView.reloadData()
        }
    }
    
    /**
     点击了标题选项
     */
    @objc private func didChangedSelected(segmentedControl: UISegmentedControl) {
        relation = segmentedControl.selectedSegmentIndex == 0 ? 1 : 0
        tableView.mj_header.beginRefreshing()
    }
    
    // MARK: - 懒加载
    /// 自定义标题
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["关注", "粉丝"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = COLOR_NAV_BG
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.addTarget(self, action: #selector(didChangedSelected(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return segmentedControl
    }()
    
}

// MARK: - Table view data source
extension JFFriendViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(friendCellIdentifier) as! JFFriendCell
        cell.relationUser = relationUsers[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let otherUser = JFOtherUserViewController()
        otherUser.userId = relationUsers[indexPath.row].relationUserId
        navigationController?.pushViewController(otherUser, animated: true)
    }
}
