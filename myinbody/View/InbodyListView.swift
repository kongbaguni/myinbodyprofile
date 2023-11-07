//
//  InbodyListView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/7/23.
//

import SwiftUI
import RealmSwift

struct InbodyListView: View {
    @ObservedRealmObject var profile:ProfileModel

    @State var error:Error? = nil {
        didSet {
            isAlert = error != nil
        }
    }
    @State var isAlert:Bool = false
    var body: some View {
        List {
            ForEach(profile.inbodys, id:\.self) { inbody in
                VStack(alignment: .leading) {
                    Text(inbody.measurementDateTime.formatted(date: .complete, time: .shortened))
                        .bold()
                    HStack {
                        Text("weight :").foregroundStyle(.secondary)
                        Text("\(inbody.weight) kg")
                        Text("BMI :").foregroundStyle(.secondary)
                        Text("\(inbody.bmi)")
                        Text("inbody point :").foregroundStyle(.secondary)
                        Text("\(inbody.inbodyPoint)")
                    }
                }
            }.onDelete { indexSet in
                for index in indexSet {
                    let inbody = profile.inbodys[index]
                    inbody.delete { error in
                        self.error = error
                    }
                }
            }
        }
        .toolbar {
            EditButton()
        }
        .alert(isPresented: $isAlert, content: {
            .init(title: .init("alert"), message: .init(error!.localizedDescription))
        })

        
        .navigationTitle(Text(profile.name))
        
    }
}

#Preview {
    InbodyListView(profile: .init(value: ["id":"test","name":"테스트"]))
}
