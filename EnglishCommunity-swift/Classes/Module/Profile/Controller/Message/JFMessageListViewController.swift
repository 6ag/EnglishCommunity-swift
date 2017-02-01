//
//  JFMessageListViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/5/23.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import MJRefresh

class JFMessageListViewController: UITableViewController {
    
    var messageRecords = [JFMessageRecord]()
    let messageRecordIdentifier = "messageRecordIdentifier"
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "消息中心"
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.separatorStyle = .none
        tableView.register(JFMessageRecordCell.classForCoder(), forCellReuseIdentifier: messageRecordIdentifier)
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(updateNewData))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(loadMoreData))
        tableView.mj_header.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        loadNews(1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadNews(pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    fileprivate func loadNews(_ pageIndex: Int, method: Int) {
        
        JFMessageRecord.getMessageList(pageIndex) { (messageRecords) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let messageRecords = messageRecords else {
                return
            }
            
            if method == 0 {
                self.messageRecords = messageRecords
            } else {
                self.messageRecords += messageRecords
            }
            
            self.tableView.reloadData()
        }
    }
    
    
}

// MARK: - Table view data source
extension JFMessageListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageRecords.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let messageRecord = messageRecords[indexPath.row]
        if Int(messageRecord.rowHeight) == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: messageRecordIdentifier) as! JFMessageRecordCell
            let height = cell.getRowHeight(messageRecord)
            messageRecord.rowHeight = height
        }
        return messageRecord.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messageRecordIdentifier) as! JFMessageRecordCell
        cell.messageRecord = messageRecords[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let messageRecord = messageRecords[indexPath.row]
        if messageRecord.type == "tweet" {
            JFProgressHUD.showWithStatus("正在加载")
            JFTweet.loadTrendsDetail(messageRecord.sourceId, finished: { (tweet) in
                JFProgressHUD.dismiss()
                guard let tweet = tweet else {
                    return
                }
                
                let detailVc = JFTweetDetailViewController()
                detailVc.tweet = tweet
                self.navigationController?.pushViewController(detailVc, animated: true)
            })
        } else {
            JFProgressHUD.showWithStatus("正在加载")
            JFVideoInfo.loadVideoInfoDetail(messageRecord.sourceId, finished: { (videoInfo) in
                JFProgressHUD.dismiss()
                guard let videoInfo = videoInfo else {
                    return
                }
                
                let playerVc = JFPlayerViewController()
                playerVc.videoInfo = videoInfo
                self.navigationController?.pushViewController(playerVc, animated: true)
            })
            
        }
        
    }
}

// MARK: - JFMessageRecordCellDelegate
extension JFMessageListViewController: JFMessageRecordCellDelegate {
    
    func messageRecordCell(_ cell: JFMessageRecordCell, didTappedAvatarButton button: UIButton) {
        guard let byUser = cell.messageRecord?.byUser else {
            return
        }
        
        let otherUser = JFOtherUserViewController()
        otherUser.userId = byUser.id
        navigationController?.pushViewController(otherUser, animated: true)
    }
}
