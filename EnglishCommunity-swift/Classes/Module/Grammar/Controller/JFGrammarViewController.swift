//
//  JFGrammarViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/4.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class JFGrammarViewController: UIViewController {

    /// 当前页码
    var page: Int = 0
    
    /// 动弹模型数组
    var grammars = [JFGrammar]()
    
    /// 动弹列表cell重用标识
    let grammarIdentifier = "grammarIdentifier"
    
    // 插页广告
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        tableView.mj_header = setupHeaderRefresh(self, action: #selector(pullDownRefresh))
        tableView.mj_footer = setupFooterRefresh(self, action: #selector(pullUpMoreData))
        tableView.mj_header.beginRefreshing()
        
        // 创建并加载插页广告
        interstitial = createAndLoadInterstitial()
    }
    
    /**
     准备UI
     */
    fileprivate func prepareUI() {
        
        navigationItem.title = "有声语法大全"
        view.backgroundColor = COLOR_ALL_BG
        view.addSubview(tableView)
    }
    
    /**
     下拉刷新
     */
    @objc fileprivate func pullDownRefresh() {
        page = 1
        updateData(page, method: 0)
    }
    
    /**
     上拉加载更多
     */
    @objc fileprivate func pullUpMoreData() {
        page += 1
        updateData(page, method: 1)
    }
    
    /**
     更新数据
     
     - parameter page:   页码
     - parameter method: 加载方式
     */
    fileprivate func updateData(_ page: Int, method: Int) {
        
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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.backgroundColor = COLOR_ALL_BG
        tableView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        tableView.register(JFGrammarListCell.classForCoder(), forCellReuseIdentifier: self.grammarIdentifier)
        return tableView
    }()
}

// MARK: - GADInterstitialDelegate 插页广告相关方法
extension JFGrammarViewController: GADInterstitialDelegate {
    
    /**
     当插页广告dismiss后初始化插页广告对象
     */
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    /**
     初始化插页广告
     
     - returns: 插页广告对象
     */
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: INTERSTITIAL_UNIT_ID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JFGrammarViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grammars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: grammarIdentifier) as! JFGrammarListCell
        cell.grammar = grammars[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 满足条件才显示广告
        if JFAccountModel.shareAccount()?.adDsabled != 1 {
            // 弹出插页广告
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
                return
            }
        }
        
        let detailVc = JFGrammarDetailViewController()
        detailVc.grammar = grammars[indexPath.row]
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
}
