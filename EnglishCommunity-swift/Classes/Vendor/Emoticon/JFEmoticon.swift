//
//  JFEmoticon.swift
//  EnglishCommunity-swift
//
//  Created by zhoujianfeng on 16/8/14.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit

// MARK: - 表情包模型
/// 表情包模型
class JFEmoticonPackage: NSObject {
    
    // MARK: - 属性
    private static let bundlePath = NSBundle.mainBundle().pathForResource("Emoticons", ofType: "bundle")!
    
    /// 表示文件夹名称
    var id: String?
    
    /// 表情包名称
    var group_name_cn: String?
    
    /// 所有表情
    var emoticons: [JFEmoticon]?
    
    /// 构造方法,通过表情包路径
    init(id: String) {
        self.id = id
        super.init()
    }
    
    //    /// 对象打印方法
    //    override var description: String {
    //        return "\n\t表情包模型: id: \(id), group_name_cn:\(group_name_cn), emoticons: \(emoticons)"
    //    }
    
    // 每次进入发微博界面弹出自定义表情键盘都会去磁盘加载所有的表情,比较耗性能,
    // 只加载一次,然后保存到内存中,以后访问内存中的表情数据
    // packages保存所有的表情包数据,只加载一次
    static let packages: [JFEmoticonPackage] = JFEmoticonPackage.loadPackages()
    
    /// 加载所有表情包
    private class func loadPackages() -> [JFEmoticonPackage] {
        //        print("加载所有的表情包")
        // 获取Emoticons.bundle的路径
        
        // 拼接 emoticons.plist 的路径
        let plistPath = bundlePath + "/emoticons.plist"
        
        // 加载plist
        let plistDict = NSDictionary(contentsOfFile: plistPath)!
        //        print("plistDict:\(plistDict)")
        
        /// 表情包数组
        var packages = [JFEmoticonPackage]()
        
        // 手动添加 `最近` 的表情包
        // 创建表情包模型
        let recent = JFEmoticonPackage(id: "")
        
        // 设置表情包名称
        recent.group_name_cn = "最近"
        
        // 添加到表情包数组
        packages.append(recent)
        
        // 初始化表情数组
        recent.emoticons = [JFEmoticon]()
        
        // 追加空白按钮和删除按钮
        recent.appendEmptyEmoticon()
        
        // 获取packages数组里面每个字典的key为id的值
        if let packageArray = plistDict["packages"] as? [[String: AnyObject]] {
            // 遍历数组
            for dict in packageArray {
                // 获取字典里面的key为id的值
                let id = dict["id"] as! String // 对应表情包的路径
                // 创建表情包,表情包里面只有id,其他的数据需要知道表情包的文件名称才能进行
                let package = JFEmoticonPackage(id: id)
                
                // 让表情包去进一步加载数据(表情模型,表情包名称)
                package.loadEmoticon()
                
                packages.append(package)
            }
        }
        
        return packages
    }
    
    /// 加载表情包里面的表情和其他数据
    func loadEmoticon() {
        // 获取表情包文件夹里面的info.plist
        // info.plist = bundle + 表情包文件夹名称 + info.plist
        let infoPath = JFEmoticonPackage.bundlePath + "/" + id! + "/info.plist"
        
        // 加载info.plist
        let infoDict = NSDictionary(contentsOfFile: infoPath)!
        //        print("infoDict:\(infoDict)")
        
        // 获取表情包名称
        group_name_cn = infoDict["group_name_cn"] as? String
        
        // 创建表情模型数组
        emoticons = [JFEmoticon]()
        
        // 记录当前是第几个按钮
        var index = 0
        // 获取表情模型
        if let array = infoDict["emoticons"] as? [[String: String]] {
            // 遍历表情数据数组
            for dict in array {
                // 字典转模型,创建表情模型
                emoticons?.append(JFEmoticon(id: id, dict: dict))
                
                index += 1
                // 如果是最后一个按钮就添加一个带删除按钮的表情模型
                if index == 20 {
                    emoticons?.append(JFEmoticon(removeEmoticon: true))
                    
                    // 记得重置为0在重新计算
                    index = 0
                }
            }
        }
        
        // 判断如果最后一个不够21个,需要追加空白表情和删除按钮
        appendEmptyEmoticon()
    }
    
    /**
     追加空白表情和删除按钮
     */
    private func appendEmptyEmoticon() {
        // 判断最后一页,表情是否满21个
        let count = emoticons!.count % 21
        
        // 不够就追加
        // 最后一页不满21个,有count个表情
        // 如果是 最近 表情包 emoticons!.count == 0
        if count > 0 || emoticons!.count == 0 {
            // 追加多少个?
            // count == 1, 追加20 - 1 = 19 (1..<20) 加上删除按钮
            // count == 2, 追加20 - 2 = 18 (2..<20)加上删除按钮
            for _ in count..<20 {
                // 追加空白按钮
                emoticons?.append(JFEmoticon(removeEmoticon: false))
            }
            
            // 追加删除按钮
            emoticons?.append(JFEmoticon(removeEmoticon: true))
        }
    }
    
    /**
     添加表情到最近表情包
     - parameter emoticon: 要添加的表情
     */
    class func addFavorate(emoticon: JFEmoticon) {
        if emoticon.removeEmoticon {
            return
        }
        
        // 表情模型的使用次数加1
        emoticon.times += 1
        
        // 找到 最近 表情包的所有模型
        var recentEmoticons = packages[0].emoticons
        
        // 不管添加多少个表情,最多只有20个表情+1删除按钮表情
        let removeEmoticon = recentEmoticons!.removeLast()
        
        // 如果最近表情包已经有这个表情,就不需要重复添加
        let contains = recentEmoticons!.contains(emoticon)
        
        // 表情包没有这个表情
        if !contains {
            recentEmoticons?.append(emoticon)
        }
        
        // 根据使用次数排序,次数多得放在前面
        recentEmoticons = recentEmoticons?.sort({ (e1, e2) -> Bool in
            // 根据 times 降序排序, 数组中,times大的排在前面,
            return e1.times > e2.times
        })
        
        // 如果前面有添加,就删除最后一个,如果没有添加不删除
        if !contains {
            // 如果前面有添加,就删除最后一个
            recentEmoticons?.removeLast()
        }
        
        // 在把删除按钮添加回来
        recentEmoticons?.append(removeEmoticon)
        
        //        print("recentEmoticons:\(recentEmoticons)")
        //        print("recentEmoticons count: \(recentEmoticons?.count)")
        // 记住要复制回去
        packages[0].emoticons = recentEmoticons
        //        print("packages[0].emoticons:\(packages[0].emoticons)")
        //        print("packages[0].emoticons count: \(packages[0].emoticons?.count)")
    }
}

// MARK: - 表情模型
/// 表情模型
class JFEmoticon: NSObject {
    
    // 表情包文件夹名称
    var id: String?
    
    // 表情名称,用于网络传输
    var chs: String?
    
    // 表情图片对应的名称
    // 直接使用这个名称是加载不到图片的,因为图片的是保存在对应的文件夹里面
    var png: String? {
        didSet {
            // 拼接完成路径
            pngPath = JFEmoticonPackage.bundlePath + "/" + id! + "/" + png!
        }
    }
    
    // 完整的图片路径 = bundle + id + png
    var pngPath: String?
    
    // emoji表情对应的16进制字符串
    var code: String? {
        didSet {
            guard let co = code else {
                // 表示code没值
                return
            }
            
            // 将code转成emoji表情
            let scanner = NSScanner(string: co)
            
            // 存储扫描结果
            // UnsafeMutablePointer<UInt32>: UInt32类型的可变指针
            var value: UInt32 = 0
            
            scanner.scanHexInt(&value)
            
            let c = Character(UnicodeScalar(value))
            
            emoji = String(c)
        }
    }
    
    // emoji表情
    var emoji: String?
    
    /// 记录点击次数
    var times = 0
    
    /// true表示 带删除按钮的表情模型, false 表示空的表情模型
    var removeEmoticon: Bool = false
    /// 带删除按钮的表情模型, 空模型
    /// 通过这个构造方法创建的模型, 要么是 带删除按钮的表情模型, 要么是 空模型
    init(removeEmoticon: Bool) {
        self.removeEmoticon = removeEmoticon
        super.init()
    }
    
    /// 字典转模型, 创建出来的不是 图片表情模型 就是emoji表情模型
    init(id: String?, dict: [String: String]) {
        self.id = id
        super.init()
        
        // KVC 赋值
        setValuesForKeysWithDictionary(dict)
    }
    
    /// 字典的key在模型里面没有对应的属性
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /// 打印方法
    override var description: String {
        return "\n\t\t表情模型: chs: \(chs), png: \(png), code: \(code)), removeEmoticon: \(removeEmoticon), times:\(times)"
    }
    
    // MARK: - 将表情模型转成带表情图片的属性文本
    /// 将表情模型转成带表情图片的属性文本
    func emoticonToAttrString(font: UIFont) -> NSAttributedString {
        guard let pngP = pngPath else {
            //            print("没有图片")
            return NSAttributedString(string: "")
        }
        
        // 创建附件
        let attachment = JFTextAttachment()
        
        // 创建 image
        let image = UIImage(contentsOfFile: pngP)
        
        // 将 image 添加到附件
        attachment.image = image
        
        // 将表情图片的名称赋值
        attachment.name = chs
        
        // 获取font的高度
        let height = font.lineHeight ?? 10
        
        // 设置附件大小
        attachment.bounds = CGRect(x: 0, y: -(height * 0.25), width: height, height: height)
        
        // 创建属性文本
        let attrString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        
        // 发现在表情图片后面在添加表情会很小.原因是前面的这个表请缺少font属性
        // 给属性文本(附件) 添加 font属性
        attrString.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: 1))
        return attrString
    }
    
    /// 根据表情文本找到对应的表情模型
    class func emoticonStringToEmoticon(emoticonString: String) -> JFEmoticon? {
        // 接收查找的结果
        var emoticon: JFEmoticon?
        
        // 遍历所有的表情模型,判断表情模型的名称 = emoticonString
        for package in JFEmoticonPackage.packages {
            // 获取对应的表情包
            let result = package.emoticons?.filter({ (e1) -> Bool in
                // 判断表情模型的表情名称是否等于 emoticonString
                // 满足条件的元素会放到数组里面作为返回结果
                return e1.chs == emoticonString
            })
            
            emoticon = result?.first
            
            // 有结果就不需要在遍历了
            if emoticon != nil {
                break
            }
        }
        
        return emoticon
    }
    
    /**
     表情字符串转带表情图片的属性文本
     - parameter string: 表情字符串
     - returns: 带表情图片的属性文本
     */
    class func emoticonStringToEmoticonAttrString(string: String, font: UIFont) -> NSAttributedString {
        // 1.解析字符串中表情文本
        // 2.根据表情文本找到对应的表情模型(表情模型里面有表情图片的完整路径) *
        // 3.将表情模型转成带表情图片的属性文本 *
        // 4.将 表情文本 替换成 表情图片的属性文本
        
        // 解析字符串中表情文本 使用正则表达式
        let pattern = "\\[.*?\\]"
        let regular = try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
        
        // 查找 string中的表情字符串
        let results = regular.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.characters.count))
        
        // 将传进来的文本转成属性文本
        let attrText = NSMutableAttributedString(string: string)
        
        // 反过来替换文本
        var count = results.count
        while count > 0 {
            
            count -= 1
            // 从最后开始获取范围
            let result = results[count]
            let range = result.rangeAtIndex(0)
            
            // 获取到对应的表情文本
            let emoticonString = (string as NSString).substringWithRange(range)
            
            // 根据表情文本找到对应的表情模型
            if let emoticon = JFEmoticon.emoticonStringToEmoticon(emoticonString) {
                // 将表情模型转成带表情图片的属性文本
                let attrString = emoticon.emoticonToAttrString(font)
                // 将 表情文本 替换成 表情图片的属性文本
                attrText.replaceCharactersInRange(range, withAttributedString: attrString)
            }
        }
        
        return attrText
    }
}
