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
    
    /// 已经准备好的广告
    var interstitials = [GADInterstitial]()
    
    /// 没有展示过的广告
    var notReadInterstitials = [GADInterstitial]()
    
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
            GADMobileAds.sharedInstance().applicationVolume = 0
            Singleton.single?.createAndLoadInterstitial()
            }
        )
        return Singleton.single!
    }
    
    /**
     获取一个插页广告对象
     
     - returns: 插页广告对象
     */
    func getReadyIntersitial() -> GADInterstitial? {
        
        if interstitials.count > 0 {
            let first = interstitials.first!
            interstitials.removeFirst()
            createAndLoadInterstitial()
            return first
        } else {
            createAndLoadInterstitial()
        }
        
        return nil
    }
    
    // MARK: - 创建广告
    /**
     创建插页广告
     */
    func createAndLoadInterstitial() {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3941303619697740/9066705318")
        interstitial.delegate = self
        interstitial.loadRequest(GADRequest())
        notReadInterstitials.append(interstitial)
    }
    
    /**
     创建悬浮广告
     
     - returns: 悬浮广告视图
     */
    func createBannerView(rootViewController: UIViewController) -> GADBannerView {
        
        let bannerView = GADBannerView()
        bannerView.rootViewController = rootViewController
        bannerView.adUnitID = "ca-app-pub-3941303619697740/2329598119"
        bannerView.loadRequest(GADRequest())
        return bannerView
    }
    
}

// MARK: - GADInterstitialDelegate
extension JFAdManager: GADInterstitialDelegate {
    
    /**
     接收到插页广告
     
     - parameter ad: 插页广告
     */
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        notReadInterstitials.removeFirst()
        interstitials.append(ad)
    }
    
    /**
     接收插页广告失败
     
     - parameter ad:    插页广告
     - parameter error: 失败对象
     */
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        notReadInterstitials.removeFirst()
    }
}
