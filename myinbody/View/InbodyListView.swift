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
            ForEach(profile.inbodys.filter("deleted = %@", false), id:\.self) { inbody in
                if inbody.deleted {
                    Text("deleted")
                } else {
                    NavigationLink {
                        InbodyDataDetailView(inbodyModel: inbody)
                    } label: {                 
                        VStack(alignment: .leading) {
                            Text(inbody.measurementDateTime.formatted(date: .complete, time: .shortened))
                                .bold()
                            HStack {
                                Text("weight :").foregroundStyle(.secondary)
                                
                                Text(String(format:"%0.1f",inbody.weight))
                                Text("kg")
                                
                                Text("BMI :").foregroundStyle(.secondary)
                                Text(String(format:"%0.0f",inbody.bmi))
                            }
                        }
                    }
                }
            }
            Section("ad"){
                NativeAdView()
            }
        }
        .refreshable {
            InbodyModel.sync(profile: profile) { error in
                self.error = error
            }
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
