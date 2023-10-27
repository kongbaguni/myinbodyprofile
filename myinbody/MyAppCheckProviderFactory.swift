//
//  AppCheckProviderFactory.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/27/23.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

class MyAppCheckProviderFactory : NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        AppAttestProvider(app: app)
    }
}
