//
//  PointHistoryView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/8/23.
//

import SwiftUI
import RealmSwift

struct PointHistoryView: View {
    @ObservedResults(PointModel.self,sortDescriptor: .init(keyPath: "regTimeIntervalSince1970", ascending: false)) var points
    @State var point:Int = 0
    
    var body: some View {
        List {
            HStack {
                Text("Current Point :")
                    .foregroundStyle(.secondary)
                Text("\(point)")
                    .bold()
                    .foregroundStyle(.primary)
                
            }
            Section {
                ForEach(points, id:\.self) { point in
                    HStack {
                        Text("\(point.value)")
                            .bold()
                            .foregroundStyle(point.value < 0 ? .red : .primary)
                        
                        Text(point.desc)
                            .foregroundStyle(.secondary)
                        Text(point.regDt.formatted(date: .complete, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
        }
        .navigationTitle(.init("points history"))
        .onAppear {
            point = PointModel.sum
        }
    }
}

#Preview {
    PointHistoryView()
}
