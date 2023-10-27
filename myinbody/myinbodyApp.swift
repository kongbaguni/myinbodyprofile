//
//  myinbodyApp.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
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
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
