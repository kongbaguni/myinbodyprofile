//
//  AdLoader.swift
//  ShootingGame
//
//  Created by Changyeol Seo on 2023/07/27.
//

import Foundation
import GoogleMobileAds

class AdLoader : NSObject {
    static let shared = AdLoader()
    
    private let adLoader:GoogleMobileAds.AdLoader
        
    private var nativeAds:[NativeAd] = []
    
    public var nativeAd:NativeAd? {
        if let ad = nativeAds.first {
            nativeAds.removeFirst()
            return ad
        }
        loadAd()
        return nil
    }
    
    public func getNativeAd(getAd:@escaping(_ ad:NativeAd)->Void) {
        if let ad = nativeAd {
            getAd(ad)
            return
        }
        loadAd()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {[weak self] in
            self?.getNativeAd(getAd: getAd)
        }
    }
    
    override init() {
        let option = MultipleAdsAdLoaderOptions()
        option.numberOfAds = 4
        adLoader = .init(adUnitID: AdIDs.nativeAd,
                         rootViewController: UIApplication.shared.lastViewController,
                         adTypes: [.native],
                         options: [option])
        super.init()
        adLoader.delegate = self
        loadAd()
    }
    
    private func loadAd() {
        adLoader.load(.init())
    }
        
}

extension AdLoader : AdLoaderDelegate {
    func adLoader(_ adLoader: GoogleMobileAds.AdLoader, didFailToReceiveAdWithError error: any Error) {
        print("\(#function) \(#line) \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GoogleMobileAds.AdLoader) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
    }
    
    
    func adLoader(_ adLoader: GoogleMobileAds.AdLoader, didReceive nativeAd: GoogleMobileAds.NativeAd) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
        nativeAds.append(nativeAd)
    }
    
}

