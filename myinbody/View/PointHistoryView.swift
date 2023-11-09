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
    
    var point:Int {
        PointModel.sum
    }
    
    @State var error:Error? = nil {
        didSet {
            isAlert = error != nil
        }
    }
    @State var isAlert:Bool = false
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
                        Text("\(point.value > 0 ? "+" : "")\(point.value)")
                            .bold()
                            .foregroundStyle(point.value < 0 ? .red : .primary)
                        Text(point.regDt.simpleString)
                            .foregroundStyle(.secondary)
                        Text(point.localizedDesc)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .refreshable {
            sync()
        }
        .alert(isPresented: $isAlert) {
            .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        }
        .navigationTitle(.init("points history"))
        .onAppear {
            sync()
        }
    }
    
    func sync() {
        PointModel.sync { error in
            self.error = error
        }
    }
}

#Preview {
    PointHistoryView()
}
