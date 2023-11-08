//
//  PointModel.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/8/23.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class PointModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var regTimeIntervalSince1970:Double = 0
    @Persisted var value:Int = 0
    @Persisted var desc:String = ""
}

extension PointModel {
    var regDt:Date {
        .init(timeIntervalSince1970: regTimeIntervalSince1970)
    }
}


fileprivate var pointRegRefId:String? = nil

extension PointModel {

    enum PointUseCase : Int {
        case createProfile = 5
        case deleteProfile = 10
        case inbodyDataInput = 1
    }
    
    static func initPoint(complete:@escaping(_ error:Error?)->Void) {
        sync { error in
            if error == nil {
                if Realm.shared.objects(PointModel.self).count == 0 {
                    PointModel.add(value: 10, desc: "first point") { error in
                        complete(error)
                    }
                } else {
                    complete(nil)
                }
            }
            else {
                complete(error)
            }
            
        }
    }
    
    static var sum:Int {
        Realm.shared.objects(PointModel.self).sum(ofProperty: "value")
    }
    
    static func sync(complete:@escaping(_ error:Error?)->Void) {
        guard let collection = FirebaseFirestoreHelper.pointCollection else {
            return
        }
        
        let regTime = Realm.shared.objects(PointModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").last?.regTimeIntervalSince1970 ?? 0
        
        collection.whereField("regTimeIntervalSince1970", isGreaterThan: regTime).getDocuments { snapShot, error in
            if error == nil {
                let realm = Realm.shared
                realm.beginWrite()
                for document in snapShot?.documents ?? [] {
                    var data = document.data()
                    data["id"] = document.documentID
                    realm.create(PointModel.self, value: data, update: .all)
                }
                try! realm.commitWrite()
            }
            complete(error)
        }
    }
     
   
    
    static func add(value:Int, desc:String, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = FirebaseFirestoreHelper.pointCollection else {
            return
        }
        var data:[String:AnyHashable] = [
            "regTimeIntervalSince1970" : Date().timeIntervalSince1970,
            "value" : value,
            "desc" : desc
        ]
        sync { error in
            if let error = error {
                complete(error)
                return
            }
            
            pointRegRefId = collection.addDocument(data: data) { error in
                if let id = pointRegRefId {
                    if error == nil {
                        data["id"] = id
                        let realm = Realm.shared
                        realm.beginWrite()
                        realm.create(PointModel.self, value: data, update: .all)
                        try! realm.commitWrite()
                    }
                    pointRegRefId = nil
                    complete(error)
                }
            }.documentID
        }
    }
    
    static func use(useCase:PointModel.PointUseCase, complete:@escaping(_ error:Error?)->Void) {
        var desc:String {
            switch useCase {
            case .createProfile:
                return "create profile"
            case .deleteProfile:
                return "delete profile"
            case .inbodyDataInput:
                return "inbody data input"
            }
        }
        use(value: useCase.rawValue, desc: desc, complete: complete)
    }
    
    static func use(value:Int, desc:String, complete:@escaping(_ error:Error?)->Void) {
        sync { error in
            if let error = error {
                complete(error)
                return
            }
            if PointModel.sum < value {
                complete(CustomError.notEnoughPoint)
                return
            }
            add(value: -value, desc: desc) { error in
                complete(error)
            }
        }
    }
    
}
