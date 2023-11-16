//
//  ProfileModel .swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import Foundation
import RealmSwift
import FirebaseFirestore

extension Notification.Name {
    static let profileModelDidUpdated = Notification.Name("profileModelDidUpdated_observer")
}

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
    func isDeleted (complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        if id.isEmpty {
            return 
        }
        collection.document(id).getDocument { snapShot, error in
            complete(snapShot?.data() == nil ? CustomError.deletedProfile : error)
        }
    }
    
    static func sync(complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        collection.getDocuments { snapshot, error in
            let realm = Realm.shared
            do {
                realm.beginWrite()
                for obj in realm.objects(ProfileModel.self) {
                    realm.delete(obj)
                }
                
                for document in snapshot?.documents ?? [] {
                    var data = document.data()
                    data["id"] = document.documentID
                    let model = realm.create(ProfileModel.self, value: data, update: .all)
                    if let id = model.profileImageId {
                        FirebaseStorageHelper.shared.getDownloadURL(uploadPath: .profileImage, id: id) { url, error in
                            if let url = url {
                                NotificationCenter.default.post(name: .profileImageUpdated, object: nil, userInfo: ["id":id, "url":url])
                            }
                        }
                    }
                }
                try realm.commitWrite()
                
            }
            catch {
                complete(error)
                return
            }
            complete(error)
        }
    }
    
    static func create(value:[String:Any], complete:@escaping(_ profileId:String, _ error:Error?)->Void) {
        PointModel.use(useCase: .createProfile) { error in
            if let error = error {
                complete("",error)
                return
            }
            
            guard let collection = collection else {
                return
            }
            
            func process(error:Error?, documentId:String) {
                if error == nil {
                    var dbData = value
                    dbData["id"] = documentId
                    do {
                        let realm = Realm.shared
                        realm.beginWrite()
                        realm.create(ProfileModel .self, value: dbData, update: .all)
                        try realm.commitWrite()
                    } catch {
                        complete(documentId, error)
                    }
                }
                complete(documentId, error)
            }
            
            FirebaseFirestoreHelper.documentReferance = collection.addDocument(data: value) { error in
                if let documentId = FirebaseFirestoreHelper.documentReferance?.documentID {
                    process(error: error, documentId: documentId)
                    FirebaseFirestoreHelper.documentReferance = nil
                }
            }

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
            do {
                if var data = snapShot?.data() {
                    data["id"] = id
                    let realm = Realm.shared
                    realm.beginWrite()
                    realm.create(ProfileModel.self,value: data, update: .all)
                    try realm.commitWrite()
                }
            } catch {
                complete(error)
                return
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
                    do {
                        let realm = Realm.shared
                        if let obj = realm.object(ofType: ProfileModel.self, forPrimaryKey: id) {
                            realm.beginWrite()
                            realm.delete(obj)
                            try realm.commitWrite()
                        }
                    } catch {
                        print(error)
                    }
                }

            }
        }
        
        func deleteInbodys(complete:@escaping(_ error:Error?)->Void) {
            let inbodyCount = inbodys.count
            var deleteCount = 0
            if inbodyCount == 0 {
                complete(nil)
                return
            }
            var err:Error? = nil
            for inbody in inbodys {
                inbody.delete { error in
                    deleteCount += 1
                    if error != nil && err == nil {
                        err = error
                    }
                    if deleteCount == inbodyCount {
                        complete(err)
                    }
                }
            }
        }
        
        PointModel.use(useCase: .deleteProfile) { error in
            if let error = error {
                complete(error)
                return
            }
            
            deleteInbodys { errorA in
                if errorA != nil {
                    complete(errorA)
                    return
                }
                collection.document(id).delete { errorB in
                    if errorB == nil {
                        deleteself()
                    }
                    complete(errorB)
                }
            }
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
