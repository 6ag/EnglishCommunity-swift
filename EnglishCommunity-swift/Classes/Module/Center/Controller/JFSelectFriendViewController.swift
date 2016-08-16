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
    var callback: ((atUsers: [[String : AnyObject]]?) -> ())?
    
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
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerNib(UINib(nibName: "JFSelectFriendCell", bundle: nil), forCellReuseIdentifier: self.selectFriendIdentifier)
        return tableView
    }()

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFSelectFriendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(selectFriendIdentifier) as! JFSelectFriendCell
        let relationUser = relationUsers[indexPath.row]
        cell.imageView?.yy_setImageWithURL(NSURL(string: relationUser.relationAvatar!), placeholder: nil)
        cell.textLabel?.text = relationUser.relationNickname!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}