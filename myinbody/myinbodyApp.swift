//
//  myinbodyApp.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import AppTrackingTransparency
import UserMessagingPlatform
import GoogleMobileAds

@main
struct myinbodyApp: App {
    init() {
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
#else
        let providerFactory = MyAppCheckProviderFactory()
#endif
        AppCheck.setAppCheckProviderFactory(providerFactory)

        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start { status in
            print("google ad status : \(status.adapterStatusesByClassName)")
            GoogleAdPrompt.promptWithDelay {
                
            }

        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
