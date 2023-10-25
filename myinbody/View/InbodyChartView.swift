//
//  InbodyChartView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/18/23.
//

import SwiftUI
import RealmSwift
import Charts

struct InbodyChartView: View {
    @ObservedRealmObject var profile:ProfileModel

    let dataType:InbodyModel.InbodyInputDataType
    let last:(date:Date,value:Double)?
    var maxCount:Int = 10
    var data:[ChartData] {
        
        var result:[ChartData] = []
        if profile.id.isEmpty {
            return []
        }
        let list = profile.inbodys.sorted(byKeyPath: "measurementDateTimeIntervalSince1970")
        
        func append(inbody:InbodyModel) {
            let date = inbody.measurementDateTime
            
            switch dataType {
            case .inbodyPoint:
                result.append(.init(date: date, value: inbody.inbodyPoint))
                
            case .measurementDate:
                result.append(.init(date: date, value: inbody.measurementDateTimeIntervalSince1970))
                
            case .height:
                result.append(.init(date: date, value: inbody.height))
                
            case .weight:
                result.append(.init(date: date, value: inbody.weight))
                
            case .skeletal_muscle_mass:
                result.append(.init(date: date, value: inbody.skeletal_muscle_mass))
                
            case .body_fat_mass:
                result.append(.init(date: date, value: inbody.body_fat_mass))
                
            case .total_body_water:
                result.append(.init(date: date, value: inbody.total_body_water))
                
            case .protein:
                result.append(.init(date: date, value: inbody.protein))
                
            case .mineral:
                result.append(.init(date: date, value: inbody.mineral))
                
            case .bmi:
                result.append(.init(date: date, value: inbody.bmi))
                
            case .percent_body_fat:
                result.append(.init(date: date, value: inbody.percent_body_fat))
                
            case .waist_hip_ratio:
                result.append(.init(date: date, value: inbody.waist_hip_ratio))
                
            case .basal_metabolic_ratio:
                result.append(.init(date: date, value: inbody.basal_metabolic_ratio))
                
            case .visceral_fat:
                result.append(.init(date: date, value: inbody.visceral_fat))
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
            result.append(.init(date: last.date, value: last.value))
        }
        return result.sorted { a, b in
            return a.date < b.date
        }
    }
    var body: some View {
        ChartView(data: data)
    }
}

struct ChartData : Identifiable {
    var id:String { date.formatted(date: .complete, time: .shortened) }
    let date:Date
    let value:Double
}

struct ChartView : View {
    let data:[ChartData]
    var body: some View {
        Chart(data) { data in
            LineMark(
                x: .value("date", data.date),
                y: .value("value", data.value)
            )
            .symbol(.circle)
        }
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.secondary, lineWidth: 1)
        }
    }
}


#Preview {
    ChartView(data: [
        .init(date: .init(timeIntervalSince1970: 1231234), value: 10),
        .init(date: .init(timeIntervalSince1970: 1232234), value: 20),
        .init(date: .init(timeIntervalSince1970: 1233234), value: 21),
        .init(date: .init(timeIntervalSince1970: 1234234), value: 40),
        .init(date: .init(timeIntervalSince1970: 1235234), value: 10),
    ])
}
