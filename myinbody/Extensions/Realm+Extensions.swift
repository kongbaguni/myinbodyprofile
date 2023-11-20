//
//  Realm+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import RealmSwift

extension Realm {
    static var shared:Realm {
        let config = Realm.Configuration(schemaVersion:5) { migration, oldSchemaVersion in
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: ProfileModel.className()) { oldObject, newObject in
                    if let update = oldObject?["regDtTimeIntervalSince1970"] as? Double {
                        newObject?["updateDtTimeIntervalSince1970"] = update
                    }
                }

            }
            if oldSchemaVersion < 2 {
                migration.enumerateObjects(ofType: InbodyModel.className()) { oldObject, newObject in
                    if let update = oldObject?["regDtTimeIntervalSince1970"] as? Double {
                        newObject?["updateDtTimeIntervalSince1970"] = update
                    }
                }
            }
        }
        return try! Realm(configuration: config)
    }
}
