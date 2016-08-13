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
let MARGIN: CGFloat = 12

/// 全局圆角
let CORNER_RADIUS: CGFloat = 5

/// 全局遮罩透明度
let GLOBAL_SHADOW_ALPHA: CGFloat = 0.5

/// 视频列表的item的间距
let LIST_ITEM_PADDING: CGFloat = 10

/// 视频列表的item宽度
let LIST_ITEM_WIDTH: CGFloat = ((SCREEN_WIDTH - 3 * 10) / 2)

/// 视频列表的item的高度
let LIST_ITEM_HEIGHT: CGFloat = (LIST_ITEM_WIDTH / 16 * 9 + 45)

/// 首页顶部分类item高度
let TOP_CATEGORY_HEIGHT: CGFloat = 100

/// 导航栏背景色 - 绿色
let COLOR_NAV_BG = UIColor(red:0.17, green:0.58, blue:0.87, alpha:1.00)

/// 所有控制器背景颜色 - 偏白
let COLOR_ALL_BG = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)

/// 导航栏ITEM默认 - 白色
let COLOR_NAV_ITEM_NORMAL = UIColor(red:0.95, green:0.98, blue:1.00, alpha:1.00)

/// 导航栏ITEM高亮 - 偏白
let COLOR_NAV_ITEM_HIGH = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)

/**
 RGB颜色构造
 */
func RGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

/**
 快速创建上拉加载更多控件
 */
func setupFooterRefresh(target: AnyObject, action: Selector) -> MJRefreshAutoNormalFooter {
    let footerRefresh = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
    footerRefresh.automaticallyHidden = true
    footerRefresh.setTitle("正在为您加载更多...", forState: MJRefreshState.Refreshing)
    footerRefresh.setTitle("上拉即可加载更多...", forState: MJRefreshState.Idle)
    footerRefresh.setTitle("没有更多数据啦...", forState: MJRefreshState.NoMoreData)
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


        