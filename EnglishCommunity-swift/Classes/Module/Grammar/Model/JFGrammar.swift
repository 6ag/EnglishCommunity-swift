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
    
    /// 标题
    var title: String?
    
    /// 内容
    var content: String?
    
    /// 音频
    var mp3: String?
    
    /// cell背景颜色16进制
    var bgHex: String?
    
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    /**
     加载语法数据
     
     - parameter page:     页码
     - parameter finished: 完成回调
     */
    class func loadGrammarData(_ page: Int, finished: @escaping (_ grammars: [JFGrammar]?) -> ()) {
        
        let parameters: [String : Any] = [
            "page" : page,
            "count" : 30,
        ]
        
        JFNetworkTools.shareNetworkTool.get(GET_GRAMMAR_MANUAL, parameters: parameters) { (success, result, error) in
            
            guard let result = result, result["status"] == "success" else {
                finished(nil)
                return
            }
            
            let data = result["result"]["data"].arrayObject as! [[String : AnyObject]]
            var grammars = [JFGrammar]()
            let bgHexs = ["41ca61", "66dc60", "83dc60", "a3dc60", "b8dc60", "a3dc60", "83dc60", "66dc60"]
            
            for (index, dict) in data.enumerated() {
                let grammar = JFGrammar(dict: dict)
                grammar.bgHex = bgHexs[index % bgHexs.count]
                grammars.append(grammar)
            }
            
            finished(grammars)
        }
    }
}
