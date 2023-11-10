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
import SwiftUI

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
    /** 갱신 일시*/
    @Persisted var updateDtTimeIntervalSince1970:Double = Date().timeIntervalSince1970
    /** 삭제됨*/
    @Persisted var deleted:Bool = false
    @Persisted(originProperty: "inbodys") var owner : LinkingObjects<ProfileModel>
    
}

extension InbodyModel {
    enum InbodyInputDataType  {
        case measurementDate
        case height
        case weight
        case skeletal_muscle_mass
        case body_fat_mass
        case total_body_water
        case protein
        case mineral
        case bmi
        case percent_body_fat
        case waist_hip_ratio
        case basal_metabolic_ratio
        case visceral_fat
        case inbodyPoint
        /** 입력을 위한 케이스 묶음*/
        static var allCases:[InbodyInputDataType] {
            [
                .measurementDate,
                .height,
                .weight,
                .skeletal_muscle_mass,
                .body_fat_mass,
                .total_body_water,
                .protein,
                .mineral,
                .percent_body_fat,
                .waist_hip_ratio,
                .basal_metabolic_ratio,
                .visceral_fat
            ]
        }
        /** 프로필에 표시할 케이스 묶음*/
        static var allCasesForProfileView:[InbodyInputDataType] {
            [
                .inbodyPoint,
                .bmi,
                .weight,
                .skeletal_muscle_mass,
                .body_fat_mass,
                .total_body_water,
                .protein,
                .mineral,
                .percent_body_fat,
                .waist_hip_ratio,
                .basal_metabolic_ratio,
                .visceral_fat
            ]
        }
        /** 수정을 위한 케이스 묶음*/
        static var allCasesForEditInbody:[InbodyInputDataType] {
            [
                .height,
                .weight,
                .skeletal_muscle_mass,
                .body_fat_mass,
                .total_body_water,
                .protein,
                .mineral,
                .percent_body_fat,
                .waist_hip_ratio,
                .basal_metabolic_ratio,
                .visceral_fat
            ]
        }
        
        var textValue: Text {
            switch self {
            case .inbodyPoint:
                return .init("inbody point")
            case .measurementDate:
                return .init("inbody input title measurementDate")
            case .height:
                return .init("inbody input title height")
            case .weight:
                return .init("inbody input title weight")
            case .skeletal_muscle_mass:
                return .init("inbody input title skeletal muscle mass")
            case .body_fat_mass:
                return .init("inbody input title body fat mass")
            case .total_body_water:
                return .init("inbody input title total body water")
            case .protein:
                return .init("inbody input title protein")
            case .mineral:
                return .init("inbody input title mineral")
            case .bmi:
                return .init("inbody input title bmi")
            case .percent_body_fat:
                return .init("inbody input title percent body fat")
            case .waist_hip_ratio:
                return .init("inbody input title waist hip ratio")
            case .basal_metabolic_ratio:
                return .init("inbody input title basal metabolic ratio")
            case .visceral_fat:
                return .init("inbody input title visceral fat")
            }
        }
        
        var unit:Text? {
            switch self {
            case .measurementDate, .inbodyPoint:
                return nil
            case .height:
                return .init("cm")
            case .weight:
                return .init("kg")
            case .skeletal_muscle_mass:
                return .init("kg")
            case .body_fat_mass:
                return .init("kg")
            case .total_body_water:
                return .init("ℓ")
            case .protein:
                return .init("kg")
            case .mineral:
                return .init("kg")
            case .bmi:
                return .init("kg/m2")
            case .percent_body_fat:
                return nil
            case .waist_hip_ratio:
                return nil
            case .basal_metabolic_ratio:
                return .init("kcal")
            case .visceral_fat:
                return nil
            }
        }
        var formatString:String {
            switch self {
            case .measurementDate:
                return ""
            case .mineral, .waist_hip_ratio:
                return "%0.2f"
            case .basal_metabolic_ratio, .visceral_fat, .height, .inbodyPoint:
                return "%0.0f"
            default:
                return "%0.1f"
            }
        }
    }
    
    var measurementDateTime : Date {
        .init(timeIntervalSince1970: measurementDateTimeIntervalSince1970)
    }
    
    var updateDateTime : Date {
        .init(timeIntervalSince1970: updateDtTimeIntervalSince1970)
    }
    
    var regDateTime : Date {
        .init(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
    
    var bmi:Double {
        let result = weight / pow(height / 100, 2)
        print("getBMI : weight: \(weight) height : \(height) result : \(result)")
        return result
    }
    
    var inbodyPoint:Double {
        (skeletal_muscle_mass / body_fat_mass / weight) * 1000
    }
    
    func getValueByType(type:InbodyModel.InbodyInputDataType)->Double {
        switch type {
        case .inbodyPoint:
            return inbodyPoint
        case .measurementDate:
            return measurementDateTimeIntervalSince1970
        case .height:
            return height
        case .weight:
            return weight
        case .skeletal_muscle_mass:
            return skeletal_muscle_mass
        case .body_fat_mass:
            return body_fat_mass
        case .total_body_water:
            return total_body_water
        case .protein:
            return protein
        case .mineral:
            return mineral
        case .bmi:
            return bmi
        case .percent_body_fat:
            return percent_body_fat
        case .waist_hip_ratio:
            return waist_hip_ratio
        case .basal_metabolic_ratio:
            return basal_metabolic_ratio
        case .visceral_fat:
            return visceral_fat
        }
    }
}



// MARK: - Firebase Firestore

extension InbodyModel {
    static func sync(profile:ProfileModel, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = FirebaseFirestoreHelper.makeInbodyCollection(profileId: profile.id) else {
            return
        }
        if profile.isInvalidated || profile.id.isEmpty {
            complete(nil)       
            return
        }
        let last = profile.inbodys.sorted(byKeyPath: "updateDtTimeIntervalSince1970").last
        let query = collection
            .whereField("updateDtTimeIntervalSince1970", isGreaterThan: last?.updateDtTimeIntervalSince1970 ?? 0)
            
        let id = profile.id
        
        query.getDocuments { snapshot, error in
            let realm = Realm.shared
            let profile = realm.object(ofType: ProfileModel.self, forPrimaryKey: id)
            
            try! realm.write {
                for document in snapshot?.documents ?? [] {
                    let id = document.documentID
                    var data = document.data()
                    data["id"] = id
                    let model = realm.create(InbodyModel.self, value: data, update: .all)
                    profile?.inbodys.append(model)
                }
            }
            complete(error)
        }

    }
    
    static func append(data:[String:Any], profile:ProfileModel, complete:@escaping(_ error:Error?)->Void) {
        guard let collection = FirebaseFirestoreHelper.makeInbodyCollection(profileId: profile.id) else {
            return
        }
        FirebaseFirestoreHelper.documentReferance = collection.addDocument(data: data) { error in
            if error == nil {
                save()
            }
            complete(error)
        }
        
        
        func save() {
            guard let id = FirebaseFirestoreHelper.documentReferance?.documentID else {
                return
            }
            var dbData = data
            dbData["id"] = id
            let realm = Realm.shared
            try! realm.write {
                let obj = realm.create(InbodyModel.self, value: dbData)
                let profile = realm.object(ofType: ProfileModel.self, forPrimaryKey: profile.id)!
                profile.inbodys.append(obj)
            }
            FirebaseFirestoreHelper.documentReferance = nil
            print(realm.objects(InbodyModel.self).count)
        }
    }
    
    func delete(complete:@escaping(_ error:Error?)->Void) {
        guard let ownerId = owner.first?.id else {
            return
        }
        
        guard let collection = FirebaseFirestoreHelper.makeInbodyCollection(profileId: ownerId) else {
            return
        }
        
        
        let id = self.id

        var data:[String:AnyHashable] = ["deleted":true, "updateDtTimeIntervalSince1970":Date().timeIntervalSince1970]
        
        collection.document(id).updateData(data) { error in
            if error == nil {
                data["id"] = id
                let realm = Realm.shared
                realm.beginWrite()
                realm.create(InbodyModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            complete(error)
        }
    }
    
    
    func save(complete:@escaping(_ error:Error?)->Void) {
        guard let profileId = owner.first?.id,
              let collection = FirebaseFirestoreHelper.makeInbodyCollection(profileId: profileId) else {
            return
        }
        var dicValue = dictionmaryValue
        let id = self.id
        dicValue["id"] = nil
        collection.document(id).setData(dicValue) { error in
            if error == nil {
                dicValue["id"] = id
                let realm = Realm.shared
                realm.beginWrite()
                realm.create(InbodyModel.self, value:dicValue, update: .all)
                try! realm.commitWrite()
            }            
            complete(error)
        }
    }
    
    func download(complete:@escaping(_ error:Error?)->Void) {
        guard let profileId = owner.first?.id,
              let collection = FirebaseFirestoreHelper.makeInbodyCollection(profileId: profileId) else {
            return
        }
        collection.document(id).getDocument { snapshot, error in
            if let documentID = snapshot?.documentID, var data = snapshot?.data() {
                data["id"] = documentID
                let realm = Realm.shared
                realm.beginWrite()
                realm.create(InbodyModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            complete(error)
        }

    }
}
