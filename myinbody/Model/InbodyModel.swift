//
//  InbodyModel.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/17/23.
////
//SkeLEral Muscle Mass)
//체지방량 (Body Fat Mass)
//체수분(Total Body Water)
//단백질 (Protein)
//
//비만진단
//BMI(Body Mass Index)
//체지방률(Percent Body Fat)
//복부지방률(Waist-Hip Ratio)
//기초대사량(Basal Metabolic Ratio)
//
//내장지방(Visceral Fat)

import Foundation
import RealmSwift
import FirebaseFirestore

class InbodyModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id:String = ""
    /** 체중 kg*/
    @Persisted var weight:Double = 0.0
    /** 신장 cm*/
    @Persisted var height:Double = 0.0
    /** 골격근량 kg*/
    @Persisted var skeletal_muscle_mass:Double = 0.0
    /** 체지방량 kg*/
    @Persisted var body_fat_mass:Double = 0.0
    /** 체수분 kg*/
    @Persisted var total_body_water:Double = 0.0
    /** 단백질 kg*/
    @Persisted var protein:Double = 0.0
    /** 무기질 kg*/
    @Persisted var mineral:Double = 0.0
    /** BIM kg/m2*/
    @Persisted var bmi:Double = 0.0
    /** 체지방률 %*/
    @Persisted var percent_body_fat:Double = 0.0
    /** 복부지방률 */
    @Persisted var waist_hip_ratio:Double = 0.0
    /** 기초대사량 kcal*/
    @Persisted var basal_metabolic_ratio:Double = 0.0
    /** 내장지방 level*/
    @Persisted var visceral_fat:Double = 0.0
    /** 측정일시*/
    @Persisted var measurementDateTimeIntervalSince1970:Double = Date().timeIntervalSince1970
    /** 등록일시**/
    @Persisted var regDtTimeIntervalSince1970:Double = Date().timeIntervalSince1970
    
    @Persisted(originProperty: "inbodys") var owner : LinkingObjects<ProfileModel>
    
}

extension InbodyModel {
    var measurementDateTime : Date {
        .init(timeIntervalSince1970: measurementDateTimeIntervalSince1970)
    }
    
    var regDateTime : Date {
        .init(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
}



// MARK: - Firebase Firestore
fileprivate var collection:CollectionReference? {
    guard let userid = AuthManager.shared.userId else {
        return nil
    }
    return Firestore.firestore().collection("data").document(userid).collection("inbody")
}

fileprivate var profileId:String = ""

extension InbodyModel {
    static func sync(profile:ProfileModel, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        
        let query = collection.document(profile.id).collection("data")
            .whereField("regDt", isGreaterThan: profile.inbodys.last?.regDtTimeIntervalSince1970 ?? 0)
            
        let id = profile.id
        
        query.getDocuments { snapshot, error in
            let realm = Realm.shared
            let profile = realm.object(ofType: ProfileModel.self, forPrimaryKey: id)
            
            try! realm.write {
                for document in snapshot?.documents ?? [] {
                    let id = document.documentID
                    var data = document.data()
                    data["id"] = id
                    let model = realm.create(InbodyModel.self, value: data)
                    profile?.inbodys.append(model)
                }
            }
            complete(error)
        }

    }
    
    static func append(data:[String:Any], profile:ProfileModel, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = collection else {
            return
        }
        let documentId = "\(UUID().uuidString)\(Date().timeIntervalSince1970)"
        let subCollection = collection.document(profile.id).collection("data")
        subCollection.document(documentId).setData(data) { error in
            if error == nil {
                save()
            }
            complete(error)
        }
        
        profileId = profile.id
        
        func save() {
            var dbData = data
            dbData["id"] = documentId
            let realm = Realm.shared
            try! realm.write {
                let obj = realm.create(InbodyModel.self, value: dbData)
                let profile = realm.object(ofType: ProfileModel.self, forPrimaryKey: profileId)!
                profile.inbodys.append(obj)
            }
            print(realm.objects(InbodyModel.self).count)
        }
    }
}
