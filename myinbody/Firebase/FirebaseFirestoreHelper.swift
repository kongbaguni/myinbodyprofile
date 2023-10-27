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
    
    static var inbodyCollection:CollectionReference? {
        guard let userid = AuthManager.shared.userId else {
            return nil
        }
        return Firestore.firestore().collection(userid).document("inbody").collection("data")
    }

}
