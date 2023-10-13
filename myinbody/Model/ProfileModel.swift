//
//  ProfileModel .swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ProfileModel  : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var name:String = ""
    @Persisted var profileImageURL:String = ""
    @Persisted var regDtTimeIntervalSince1970:Double = 0
}

extension ProfileModel  {
    var regDt:Date {
        .init(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
}

// MARK: - Firebase Firestore
fileprivate var collection:CollectionReference? {
    guard let userid = AuthManager.shared.userId else {
        return nil
    }
    return Firestore.firestore().collection("data").document(userid).collection("profile")
}

extension ProfileModel  {
    static func sync(complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        collection.getDocuments { snapshot, error in
            let realm = Realm.shared
            try! realm.write {
                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    data["id"] = document.documentID
                    realm.create(ProfileModel .self, value: data, update: .all)
                }
            }
        }
    }
    static func create(id:String? = nil ,value:[String:Any], complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        let documentId = id ?? UUID().uuidString
        collection.document(documentId).setData(value) { error in
            if error == nil {
                var dbData = value
                dbData["id"] = documentId
                
                let realm = Realm.shared
                try! realm.write {
                    realm.create(ProfileModel .self, value: dbData, update: .all)
                }
            }
            complete(error)
        }
    }
    
    func delete(removeWithLocal:Bool = false ,complete:@escaping (_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        
        func deleteself()  {
            if removeWithLocal {
                let realm = Realm.shared
                try! realm.write {
                    realm.delete(self)
                }
            }
        }
        
        collection.document(id).delete { error in
            if error == nil {
                deleteself()
            }
            complete(error)
        }
    }
}

//MARK: - ObservableObject
class PeopleResultsWrapper: ObservableObject {
    @Published var people: Results<ProfileModel >
    
    init(people: Results<ProfileModel >) {
        self.people = people
    }
}
