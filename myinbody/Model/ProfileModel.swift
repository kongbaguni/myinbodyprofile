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
    var lastInbody:InbodyModel? {
        inbodys.sorted(byKeyPath: "measurementDateTimeIntervalSince1970", ascending: true).last
    }
    
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
    FirebaseFirestoreHelper.profileCollectiuon
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
        if id.isEmpty {
            return 
        }
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
        dicValue["inbodys"] = nil 
        print("updateProfile : \(dicValue.count)")
        for item in dicValue {
            print("\(item.key) \(item.value)")
        }
        
        collection.document(id).setData(dicValue) { error in
            complete(error)
        }
    }
    
    func delete(removeWithLocal:Bool = false, isDeletedProfileImage:Bool? = nil ,isDeletedInbodyData:Bool? = nil ,complete:@escaping (_ error:Error?)->Void) {
        
        let id = self.id
        if id.isEmpty {
            return 
        }

        if profileImageURL != nil && isDeletedProfileImage != true {
            if let id = profileImageId {
                FirebaseStorageHelper.shared.delete(path: .profileImage, id: id) { error in
                    if error == nil {
                        _ = FirestorageDownloadUrlCacheModel.remove(id: id)
                    }
                    self.delete(removeWithLocal: removeWithLocal,isDeletedProfileImage: true ,complete: complete)
                }
                return
            }
        }
        guard let collection = collection else {
            return
        }
        
        func deleteself()  {
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
        
        if inbodys.count > 0 && isDeletedInbodyData == nil {
            if let collection = FirebaseFirestoreHelper.inbodyCollection {
                
                collection.document(id).delete { error in
                    if error == nil {
                        self.delete(removeWithLocal: removeWithLocal, isDeletedProfileImage: isDeletedProfileImage, isDeletedInbodyData: true, complete: complete)
                    } else {
                        print(error!.localizedDescription)
                        abort()
                    }
                }
                return
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
