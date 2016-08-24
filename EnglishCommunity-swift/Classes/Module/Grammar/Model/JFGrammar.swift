//
//  JFGrammar.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/12.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

class JFGrammar: NSObject {
    
    var id = 0
    
    var title: String?
    
    var content: String?
    
    init(dict: [String : AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /**
     加载语法数据
     
     - parameter page:     页码
     - parameter finished: 完成回调
     */
    class func loadGrammarData(page: Int, finished: (grammars: [JFGrammar]?) -> ()) {
        
        let parameters: [String : AnyObject] = [
            "page" : page,
            "count" : 20,
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_GRAMMAR_MANUAL, parameters: parameters) { (success, result, error) in
            
            guard let result = result where result["status"] == "success" else {
                finished(grammars: nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var grammars = [JFGrammar]()
            
            for dict in data {
                grammars.append(JFGrammar(dict: dict))
            }
            
            finished(grammars: grammars)
        }
    }
}
