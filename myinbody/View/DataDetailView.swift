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
    
    var chartData:[ChartData] {
        datas.map { model in
            .init(date: model.measurementDateTime, value: model.getValueByType(type: dataType))
        }
    }
    
    func setIdx(lastIdx:Int?) {
        to = lastIdx ?? profile.inbodys.count
        if to > profile.inbodys.count {
            to = profile.inbodys.count
        }
        from = to - rows
        if from < 0 {
            from = 0
        }
    }
    
    var datas:Slice<Results<InbodyModel>> {
        return profile.inbodys.sorted(byKeyPath: "measurementDateTimeIntervalSince1970")[from..<to]
    }

    var body: some View {
        List {
            ChartView(data: chartData)
            if from > 0 {
                Button {
                    setIdx(lastIdx: to - rows)
                } label: {
                    ImageTextView(image: .init(systemName: "arrow.up.square"),
                                  text: .init("Before"))
                }
            }
            ForEach(datas, id:\.self) {data in
                HStack {
                    Text(data.measurementDateTime.formatted(date: .complete, time: .shortened))
                        .foregroundStyle(.secondary)
                        .font(.system(size: 10))
                    let value:Double = data.getValueByType(type: dataType)
                    Text(String(format: dataType.formatString, value))
                        .foregroundStyle(.primary)
                        .fontWeight(.bold)
                    if let unit = dataType.unit {
                        unit.font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if to < profile.inbodys.count {
                Button {
                    setIdx(lastIdx: to + rows)
                } label : {
                    ImageTextView(image: .init(systemName: "arrow.down.square"),
                                  text: .init("After"))

                }
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
