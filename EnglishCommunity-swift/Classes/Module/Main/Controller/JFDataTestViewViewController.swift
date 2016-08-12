//
//  JFDataTestViewViewController.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFDataTestViewViewController: UIViewController {
    
    var page = 0
    
    let cate = 1360
    let gramar_categoryies_id = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.grayColor()
    }

    @IBAction func startGather(sender: UIButton) {
        page += 1
        loadData(cate, page: page)
    }
    
    /**
     加载列表
     */
    func loadData(id: Int, page: Int) {
        
        let parameters: [String : AnyObject] = [
            "json" : "get_category_posts",
            "id" : id,
            "page" : page
        ]
        
        JFNetworkTools.shareNetworkTool.get("http://my.idwoo.com/api", parameters: parameters) { (success, result, error) in
            guard let result = result where success == true else {
                print("没有数据了")
                return
            }
            
            let array = result["posts"].arrayObject as! [[String : AnyObject]]
            for dict in array {
                self.loadContent(Int(dict["id"]!.intValue))
            }
            
        }
    }
    
    /**
     加载详情
     */
    func loadContent(id: Int) {
        
        let parameters: [String : AnyObject] = [
            "post_id" : id,
        ]
        
        JFNetworkTools.shareNetworkTool.get("http://my.idwoo.com/api/get_post", parameters: parameters) { (success, result, error) in
            guard let result = result where success == true else {
                print("没有数据了")
                return
            }
            
            let title = result["post"]["title"].stringValue
            let content = result["post"]["content"].stringValue
            self.insertData(title, content: content)
        }
    }
    
    /**
     插入数据
     */
    func insertData(title: String, content: String) {
        
        let parameters: [String : AnyObject] = [
            "title" : title,
            "contents" : content,
            "gramar_categoryies_id" : gramar_categoryies_id
            ]
        
        JFNetworkTools.shareNetworkTool.post("api/insertGramarData.api", parameters: parameters) { (success, result, error) in
            guard let result = result where success == true else {
                print("插入数据失败")
                return
            }
            
            print("插入数据成功", result)
            
        }
    }
    

}
