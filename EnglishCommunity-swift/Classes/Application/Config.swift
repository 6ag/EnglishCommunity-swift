//
//  Config.swift
//  BaiSiBuDeJie-swift
//
//  Created by zhoujianfeng on 16/7/16.
//  Copyright © 2016年 zhoujianfeng. All rights reserved.
//

import UIKit
import MJRefresh

let SCREEN_BOUNDS = UIScreen.mainScreen().bounds
let SCREEN_WIDTH = SCREEN_BOUNDS.width
let SCREEN_HEIGHT = SCREEN_BOUNDS.height

/// 全局边距
let MARGIN: CGFloat = 15

/// 全局圆角
let CORNER_RADIUS: CGFloat = 5

/// 全局遮罩透明度
let GLOBAL_SHADOW_ALPHA: CGFloat = 0.5

/// 视频列表的item的间距
let LIST_ITEM_PADDING: CGFloat = 10

/// 首页列表的item宽度
let LIST_ITEM_WIDTH: CGFloat = ((SCREEN_WIDTH - 3 * 10) / 2)

/// 首页列表的item的高度
let LIST_ITEM_HEIGHT: CGFloat = (LIST_ITEM_WIDTH / 16 * 9 + 58)

/// 导航栏背景色 - 绿色
let COLOR_NAV_BG = UIColor.colorWithHexString("41ca61")

/// 所有控制器背景颜色 - 偏白
let COLOR_ALL_BG = UIColor.colorWithHexString("f7f7f7")

/// 导航栏ITEM默认 - 白色
let COLOR_NAV_ITEM_NORMAL = UIColor(red:0.95, green:0.98, blue:1.00, alpha:1.00)

/// 导航栏ITEM高亮 - 偏白
let COLOR_NAV_ITEM_HIGH = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)

/**
 RGB颜色构造
 */
func RGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
}

/**
 快速创建上拉加载更多控件
 */
func setupFooterRefresh(target: AnyObject, action: Selector) -> MJRefreshFooter {
    let footerRefresh = MJRefreshBackNormalFooter(refreshingTarget: target, refreshingAction: action)
    footerRefresh.automaticallyHidden = true
    footerRefresh.setTitle("正在加载", forState: MJRefreshState.Refreshing)
    footerRefresh.setTitle("上拉加载更多", forState: MJRefreshState.Idle)
    footerRefresh.setTitle("没有啦~~~", forState: MJRefreshState.NoMoreData)
    return footerRefresh
}

/**
 快速创建下拉加载最新控件
 */
func setupHeaderRefresh(target: AnyObject, action: Selector) -> MJRefreshNormalHeader {
    let headerRefresh = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    headerRefresh.lastUpdatedTimeLabel.hidden = true
    headerRefresh.stateLabel.hidden = true
    return headerRefresh
}

/**
 判断是否登录，如果没有登录则跳转到登录界面
 
 - parameter controller: 当前控制器
 
 - returns: 是否已经登录
 */
func isLogin(controller: UIViewController) -> Bool {
    
    if JFAccountModel.isLogin() {
        return true
    } else {
        let loginVc = JFNavigationController(rootViewController: JFLoginViewController(nibName: "JFLoginViewController", bundle: nil))
        controller.presentViewController(loginVc, animated: true, completion: { 
            print("弹出登录界面")
        })
        return false
    }
}
        