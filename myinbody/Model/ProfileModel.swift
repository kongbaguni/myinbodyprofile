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
    @Persisted var regDtTimeIntervalSince1970:Double = 0
    @Persisted var inbodys: List<InbodyModel>
}

extension ProfileModel  {
    var regDt:Date {
        .init(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
    var profileImageId:String? {
        guard let uid = AuthManager.shared.userId else {
            return nil
        }
        return "\(uid)/\(id)"
    }
    
    var profileImageURL:String? {
        if let id = profileImageId {
            if let object = FirestorageDownloadUrlCacheModel.get(id: id) {
                FirebaseStorageHelper.shared.getDownloadURL(uploadPath: .profileImage, id: id) { url, error in
                    
                }
                let url = object.url
                return url
            }
            FirebaseStorageHelper.shared.getDownloadURL(uploadPath: .profileImage, id: id) { url, error in
                if let url = url {
                    _ = FirestorageDownloadUrlCacheModel.reg(id: id, url: url.absoluteString)
                }
            }
            
        }
        return nil
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
                    let model = realm.create(ProfileModel .self, value: data, update: .all)
                    if let id = model.profileImageId {
                        FirebaseStorageHelper.shared.getDownloadURL(uploadPath: .profileImage, id: id) { url, error in
                            if let url = url {
                                NotificationCenter.default.post(name: .profileImageUpdated, object: nil, userInfo: ["id":id, "url":url])
                            }
                        }
                    }

                }
            }
        }
    }
    static func create(documentId:String ,value:[String:Any], complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
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
    
    func downloadFirestore(complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        let id = self.id
        collection.document(id).getDocument { snapShot, error in
            if var data = snapShot?.data() {
                data["id"] = id
                let realm = Realm.shared
                try! realm.write {
                    realm.create(ProfileModel.self,value: data, update: .all)
                }
            }
            complete(error)
        }
    }
    
    func updateFirestore(complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        var dicValue = dictionmaryValue
        dicValue["id"] = nil
        collection.document(id).setData(dictionmaryValue) { error in
            complete(error)
        }
    }
    
    func delete(removeWithLocal:Bool = false ,complete:@escaping (_ error:Error?)->Void) {
        if profileImageURL != nil  {
            if let id = profileImageId {
                FirebaseStorageHelper.shared.delete(path: .profileImage, id: id) { error in
                    self.delete(removeWithLocal: removeWithLocal, complete: complete)
                }
                return
            }
        }
        guard let collection = collection else {
            return
        }
        
        func deleteself()  {
            let id = self.id
            DispatchQueue.main.async {
                if removeWithLocal {
                    let realm = Realm.shared
                    if let obj = realm.object(ofType: ProfileModel.self, forPrimaryKey: id) {
                        try! realm.write {
                            realm.delete(obj)
                        }
                    }
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
