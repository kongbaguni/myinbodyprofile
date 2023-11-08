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
        }
        
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        GoogleAdPrompt.promptWithDelay {
            
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
