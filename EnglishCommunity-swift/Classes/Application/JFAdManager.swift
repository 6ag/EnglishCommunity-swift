//
//  JFAdManager.swift
//  JianSanWallpaper
//
//  Created by zhoujianfeng on 16/8/13.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class JFAdManager: NSObject {
    
    /// 插页广告id
    let interstitialUnitId = "ca-app-pub-3941303619697740/5655470113"
    
    /// 横幅广告id
    let bannerUnitId = "ca-app-pub-3941303619697740/4039136115"
    
    /// 已经准备好的广告
    var interstitial: GADInterstitial?
    
    /**
     广告管理单利
     */
    static func shareDbManager() -> JFAdManager {
        struct Singleton {
            static var onceToken : dispatch_once_t = 0
            static var single:JFAdManager?
        }
        dispatch_once(&Singleton.onceToken, {
            Singleton.single = JFAdManager()
            Singleton.single?.createAndLoadInterstitial()
            }
        )
        return Singleton.single!
    }
    
    // MARK: - 获取广告
    /**
     获取一个插页广告对象
     
     - returns: 插页广告对象
     */
    func getReadyIntersitial() -> GADInterstitial? {
        if let interstitial = interstitial {
            createAndLoadInterstitial()
            return interstitial
        } else {
            createAndLoadInterstitial()
            return nil
        }
    }
    
    /**
     获取一个悬浮广告视图
     
     - parameter rootViewController: 将展显示的控制器
     
     - returns: 悬浮广告视图
     */
    func getBannerView(rootViewController: UIViewController) -> GADBannerView {
        return createBannerView(rootViewController)
    }
    
    /**
     获取一个原生广告
     
     - parameter rootViewController: 将展示的控制器
     
     - returns: 悬浮广告视图
     */
    func getNativeView(rootViewController: UIViewController) -> GADNativeExpressAdView {
        return createNativeExpressView(rootViewController)
    }
    
    
    // MARK: - 创建广告
    /**
     创建插页广告
     */
    private func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: interstitialUnitId)
        if let interstitial = interstitial {
            interstitial.loadRequest(GADRequest())
        }
    }
    
    /**
     创建悬浮广告
     */
    private func createBannerView(rootViewController: UIViewController) -> GADBannerView {
        let bannerView = GADBannerView()
        bannerView.rootViewController = rootViewController
        bannerView.adUnitID = bannerUnitId
        bannerView.loadRequest(GADRequest())
        return bannerView
    }
    
    /**
     创建原生广告 - 分类cell
     */
    private func createNativeExpressView(rootViewController: UIViewController) -> GADNativeExpressAdView {
        let nativeExpressView = GADNativeExpressAdView()
        nativeExpressView.adUnitID = NATIVE_UNIT_ID
        nativeExpressView.rootViewController = rootViewController
        nativeExpressView.loadRequest(GADRequest())
        return nativeExpressView
    }
    
}
