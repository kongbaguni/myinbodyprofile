//
//  InbodyChartView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/18/23.
//

import SwiftUI
import RealmSwift
import SwiftUICharts
import Charts

struct InbodyChartView: View {
    @ObservedRealmObject var profile:ProfileModel

    let dataType:InbodyModel.InbodyInputDataType
    let last:Double?
    var maxCount:Int = 2
    var data:([Double],[ChartData]) {
        
        var result:[Double] = []
        var result2:[ChartData] = []
        
        let list = profile.inbodys.sorted(byKeyPath: "measurementDateTimeIntervalSince1970")
        
        func append(inbody:InbodyModel) {
            let date = inbody.measurementDateTime.formatting(format: "\(result.count+1)")
            
            switch dataType {
            case .measurementDate:
                result.append(inbody.measurementDateTimeIntervalSince1970)
                result2.append(.init(date: date, value: inbody.measurementDateTimeIntervalSince1970))
                
            case .height:
                result.append(inbody.height)
                result2.append(.init(date: date, value: inbody.height))
                
            case .weight:
                result.append(inbody.weight)
                result2.append(.init(date: date, value: inbody.weight))
                
            case .skeletal_muscle_mass:
                result.append(inbody.skeletal_muscle_mass)
                result2.append(.init(date: date, value: inbody.skeletal_muscle_mass))
                
            case .body_fat_mass:
                result.append(inbody.body_fat_mass)
                result2.append(.init(date: date, value: inbody.body_fat_mass))
                
            case .total_body_water:
                result.append(inbody.total_body_water)
                result2.append(.init(date: date, value: inbody.total_body_water))
                
            case .protein:
                result.append(inbody.protein)
                result2.append(.init(date: date, value: inbody.protein))
                
            case .mineral:
                result.append(inbody.mineral)
                result2.append(.init(date: date, value: inbody.mineral))
                
            case .bmi:
                result.append(inbody.bmi)
                result2.append(.init(date: date, value: inbody.bmi))
                
            case .percent_body_fat:
                result.append(inbody.percent_body_fat)
                result2.append(.init(date: date, value: inbody.percent_body_fat))
                
            case .waist_hip_ratio:
                result.append(inbody.waist_hip_ratio)
                result2.append(.init(date: date, value: inbody.waist_hip_ratio))
                
            case .basal_metabolic_ratio:
                result.append(inbody.basal_metabolic_ratio)
                result2.append(.init(date: date, value: inbody.basal_metabolic_ratio))
                
            case .visceral_fat:
                result.append(inbody.visceral_fat)
                result2.append(.init(date: date, value: inbody.visceral_fat))
            }
        }
        if list.count < maxCount {
            for inbody in list {
                append(inbody: inbody)
            }
        } else {
            let last = list.count
            let first = last - maxCount
            for inbody in list[first..<last] {
                append(inbody: inbody)
            }
        }
        
        if let last = last {
            result.append(last)
        }
        return (result,result2)
    }
    var body: some View {
        if last != nil {
            LineView(data: data.0)
        } else {
            ChartView(data: data.1)
        }
    }
}

struct ChartData : Identifiable {
    var id:String { date }
    let date:String
    let value:Double
}
struct ChartView : View {
    let data:[ChartData]
    var body: some View {
        VStack {
            Chart(data) { data in
                LineMark(x: .value("date", data.date), y: .value("value", data.value))
                    .symbol(.circle)
                
            }
        }
        
    }
}


#Preview {
    ChartView(data: [
        .init(date: "3.9", value: 10),
        .init(date: "3.10", value: 20),
        .init(date: "4.1", value: 21),
        .init(date: "4.2", value: 40),
        .init(date: "4.3", value: 10),
    ])
//    InbodyChartView(profile: .init(value: ["id":"test","name":"홍길동"]), dataType: .height, last: 20, maxCount: 10)
}
