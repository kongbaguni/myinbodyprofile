//
//  InbodyChartView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/18/23.
//

import SwiftUI
import RealmSwift
import SwiftUICharts

struct InbodyChartView: View {
    @ObservedRealmObject var profile:ProfileModel

    let dataType:InbodyModel.InbodyInputDataType
    let last:Double
    var data:[Double] {
        var result:[Double] = []
        for inbody in profile.inbodys {
            switch dataType {
            case .measurementDate:
                break
            case .height:
                result.append(inbody.height)
            case .weight:
                result.append(inbody.weight)
            case .skeletal_muscle_mass:
                result.append(inbody.skeletal_muscle_mass)
            case .body_fat_mass:
                result.append(inbody.body_fat_mass)
            case .total_body_water:
                result.append(inbody.total_body_water)
            case .protein:
                result.append(inbody.protein)
            case .mineral:
                result.append(inbody.mineral)
            case .bmi:
                result.append(inbody.bmi)
            case .percent_body_fat:
                result.append(inbody.percent_body_fat)
            case .waist_hip_ratio:
                result.append(inbody.waist_hip_ratio)
            case .basal_metabolic_ratio:
                result.append(inbody.basal_metabolic_ratio)
            case .visceral_fat:
                result.append(inbody.visceral_fat)
            }
        }
        result.append(last)
        return result
    }
    var body: some View {
        LineView(data: data)
    }
}

#Preview {
    InbodyChartView(profile: .init(value: ["id":"test","name":"홍길동"]), dataType: .height, last: 20)
}
