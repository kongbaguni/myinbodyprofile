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
    @Persisted var measurementDate:Date = .init()
    @Persisted(originProperty: "inbodys") var owner : LinkingObjects<ProfileModel>
    
}
