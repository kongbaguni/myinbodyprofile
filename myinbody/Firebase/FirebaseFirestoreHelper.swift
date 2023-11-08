//
//  FirestoreHelper.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import FirebaseFirestore
import RealmSwift
import SwiftUI

struct FirebaseFirestoreHelper {
    static var documentReferance:DocumentReference? = nil

    static var profileCollectiuon:CollectionReference? {
        guard let userid = AuthManager.shared.userId else {
            return nil
        }
        return Firestore.firestore().collection(userid).document("profile").collection("data")
    }
    
    static func makeInbodyCollection(profileId:String)->CollectionReference? {
        guard profileId.isEmpty == false else {
            return nil
        }
        guard let userid = AuthManager.shared.userId else {
            return nil
        }
        return Firestore.firestore().collection(userid).document("inbody").collection(profileId)
    }
    
    static var pointCollection:CollectionReference? {
        guard let userid = AuthManager.shared.userId else {
            return nil
        }
        return Firestore.firestore().collection(userid).document("point").collection("data")
    }

}
