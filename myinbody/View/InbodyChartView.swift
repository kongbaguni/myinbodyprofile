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
    @AppStorage("bmrtype") var bmrType:ProfileModel.BMRType = .harrisBenedict
    
    let dataType:InbodyModel.InbodyInputDataType
    let last:(date:Date,value:Double)?
    var maxCount:Int = 10
    var data:(first:[ChartData],second:[ChartData]) {
        
        var first:[ChartData] = []
        var second:[ChartData] = []
        if profile.id.isEmpty {
            return (first:[],second:[])
        }
        let list = profile.inbodys.filter("deleted = %@", false).sorted(byKeyPath: "measurementDateTimeIntervalSince1970")
        
        func append(inbody:InbodyModel) {
            let date = inbody.measurementDateTime
            
            switch dataType {
            case .inbodyPoint:
                first.append(.init(date: date, value: inbody.inbodyPoint))
                
            case .measurementDate:
                first.append(.init(date: date, value: inbody.measurementDateTimeIntervalSince1970))
                
            case .height:
                first.append(.init(date: date, value: inbody.height))
                
            case .weight:
                first.append(.init(date: date, value: inbody.weight))
                
            case .skeletal_muscle_mass:
                first.append(.init(date: date, value: inbody.skeletal_muscle_mass))
                
            case .body_fat_mass:
                first.append(.init(date: date, value: inbody.body_fat_mass))
                
            case .total_body_water:
                first.append(.init(date: date, value: inbody.total_body_water))
                
            case .protein:
                first.append(.init(date: date, value: inbody.protein))
                
            case .mineral:
                first.append(.init(date: date, value: inbody.mineral))
                
            case .bmi:
                first.append(.init(date: date, value: inbody.bmi))
                
            case .percent_body_fat:
                first.append(.init(date: date, value: inbody.percent_body_fat))
                
            case .waist_hip_ratio:
                first.append(.init(date: date, value: inbody.waist_hip_ratio))
                
            case .basal_metabolic_ratio:
                first.append(.init(date: date, value: inbody.basal_metabolic_ratio))
                second.append(.init(date: date, value: inbody.getBMR(type: bmrType)))
                
            case .visceral_fat:
                first.append(.init(date: date, value: inbody.visceral_fat))
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
            first.append(.init(date: last.date, value: last.value))
        }
        
        return ( first : first.sorted { a, b in
            a.date < b.date
        }, second : second.sorted(by: { a, b in
            a.date < b.date
        }))
    }
    var body: some View {
        ZStack {
            ChartView(data: data.first, selectData: nil)
            if data.second.count > 0 {
                ChartView(data: data.second, selectData: nil)
                    .opacity(0.2)
            }
        }
    }
}

struct ChartData : Identifiable {
    var id:String { date.formatted(date: .complete, time: .shortened) }
    let date:Date
    let value:Double
}

struct ChartView : View {
    let data:[ChartData]
    let selectData:ChartData?
    var body: some View {
        Chart(data) { data in
            LineMark(
                x: .value("date", data.date),
                y: .value("value", data.value)
            )
            .symbol(selectData?.id == data.id ? .square : .circle)
            .symbolSize(selectData?.id == data.id ? 100 : 25)
            .foregroundStyle(Color("chartLineColor"))            
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
    ],selectData: nil)
}
