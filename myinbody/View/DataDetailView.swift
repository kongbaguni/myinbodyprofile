//
//  DataDetailView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/23/23.
//

import SwiftUI
import RealmSwift
import Charts

struct DataDetailView: View {
    @ObservedRealmObject var profile:ProfileModel
    
    let dataType:InbodyModel.InbodyInputDataType
    let rows:Int
    @State var from = 0
    @State var to = 0
    @State var selectedChartData:ChartData? = nil
    @AppStorage("bmrtype") var bmrType:ProfileModel.BMRType = .harrisBenedict
    
    var chartData:[ChartData] {
        datas.map { model in
            .init(date: model.measurementDateTime, value: model.getValueByType(type: dataType))
        }
    }
    
    var secondChartData:[ChartData]? {
        switch dataType {
        case .basal_metabolic_ratio:
            return datas.map { model in
                    .init(date: model.measurementDateTime, value: model.getBMR(type: bmrType))
            }
        default:
            return nil
        }
    }
    
    func setIdx(lastIdx:Int?) {
        let list = profile.inbodys.filter("deleted = %@",false)
        to = lastIdx ?? list.count
        if  list.count > 0 &&
                to > list.count {
            to = list.count
        }
        from = to - rows
        if from < 0 {
            from = 0
        }
    }
    
    var datas:Slice<Results<InbodyModel>> {
        return profile.inbodys.filter("deleted = %@", false).sorted(byKeyPath: "measurementDateTimeIntervalSince1970")[from..<to]
    }

    var body: some View {
        List {
            Section {
                ZStack {
                    ChartView(data: chartData, selectData:selectedChartData)
                    if let data = secondChartData {
                        ChartView(data: data, selectData:selectedChartData)
                            .opacity(0.2)
                    }
                }
            }
            if from > 0 {
                Button {
                    setIdx(lastIdx: to - rows)
                } label: {
                    ImageTextView(image: .init(systemName: "arrow.up.square"),
                                  text: .init("Before"))
                }
            }
            ForEach(datas, id:\.self) { data in
                let cdata = ChartData(date: data.measurementDateTime, value: data.getValueByType(type: dataType))
                Button {
                    if selectedChartData?.id == cdata.id {
                        selectedChartData = nil
                    } else {
                        selectedChartData = cdata
                    }
                } label: {
                    HStack {                        
                        if cdata.id == selectedChartData?.id {
                            Image(systemName: "circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                        Text(data.measurementDateTime.formatted(date: .complete, time: .shortened))
                            .foregroundStyle(.secondary)
                            .font(.system(size: 10))
                        let value:Double = data.getValueByType(type: dataType)
                        Text(String(format: dataType.formatString, value))
                            .foregroundStyle(.orange)
                            .fontWeight(.bold)
                        if let unit = dataType.unit {
                            unit.font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if dataType == .basal_metabolic_ratio {
                            Text("BMR :")
                            let value = data.getBMR(type: bmrType)
                            Text(String(format: dataType.formatString, value))
                                .foregroundStyle(.green)
                                .fontWeight(.bold)
                            if let unit = dataType.unit {
                                unit.font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            if to < profile.inbodys.filter("deleted = %@",false).count {
                Button {
                    setIdx(lastIdx: to + rows)
                } label : {
                    ImageTextView(image: .init(systemName: "arrow.down.square"),
                                  text: .init("After"))
                    
                }
            }
            Section("ad") {
                NativeAdView()
            }
        }
        .onAppear {
            setIdx(lastIdx: nil)
        }
        .navigationTitle(dataType.textValue)
    }
}

#Preview {
    DataDetailView(profile: .init(value: ["id":"test", "name":"홍길동"]), dataType: .bmi, rows: 10)
}
