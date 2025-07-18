//
//  AdIDs.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/8/23.
//

import Foundation

enum AdIDs {
    #if DEBUG
    static let nativeAd = "ca-app-pub-3940256099942544/3986624511"
    static let rewardAd = "ca-app-pub-3940256099942544/1712485313"
    #else
    static let nativeAd = "ca-app-pub-7714069006629518/9996550187"
    static let rewardAd = "ca-app-pub-7714069006629518/9140432386"
    #endif
}
