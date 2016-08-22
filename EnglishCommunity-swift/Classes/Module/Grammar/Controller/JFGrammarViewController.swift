//
//  JFGrammarViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFGrammarViewController: UIViewController {

    /// 当前页码
    var page: Int = 0
    
    /// 动弹模型数组
    var grammars = [JFGrammar]()
    
    /// 动弹列表cell重用标识
    let grammarIdentifier = "grammarIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        tableView.mj_header.beginRefreshing()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
    }
    
    /**
     下拉刷新
     */
    @objc private func pullDownRefresh() {
        page = 1
        updateData(page, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc private func pullUpMoreData() {
        page += 1
        updateData(page, method: 1)
    }
    
    /**
     更新数据
     
     - parameter page:   页码
     - parameter method: 加载方式
     */
    private func updateData(page: Int, method: Int) {
        
        JFGrammar.loadGrammarData(page) { (grammars) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let grammars = grammars else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            if method == 0 {
                self.grammars = grammars
            } else {
                self.grammars += grammars
            }
            
            self.tableView.reloadData()
        }
    }
    
    /// 内容区域
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.registerClass(JFGrammarListCell.classForCoder(), forCellReuseIdentifier: self.grammarIdentifier)
        return tableView
    }()
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFGrammarViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grammars.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(grammarIdentifier) as! JFGrammarListCell
        cell.grammar = grammars[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let detailVc = JFGrammarDetailViewController()
        detailVc.grammar = grammars[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}
