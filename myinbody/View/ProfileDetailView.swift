//
//  ProfileDetailView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift

struct ProfileDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedRealmObject var profile:ProfileModel

    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    
    var deletedView : some View {
        Text("")
            .onAppear {
                presentationMode.wrappedValue.dismiss()
            }
            .navigationTitle("")
    }
    
    var normalView : some View {
        List {
            Section {
                HStack(alignment:.top) {
                    ProfileImageView(profile: profile, size: .init(width: 150, height: 150))
                        .frame(height: 150)
                    VStack(alignment:.leading) {
                        HStack {
                            Text("name :")
                                .foregroundStyle(.secondary)
                            Text(profile.name)
                                .font(.system(size: 40))
                                .bold()
                                .foregroundStyle(.primary)
                        }
                        HStack {
                            Text("regDt :")
                                .foregroundStyle(.secondary)
                            Text(profile.regDt.formatted(date: .complete, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if profile.inbodys.count > 0 {
                Section {
                    ForEach(InbodyModel.InbodyInputDataType.allCasesForProfileView, id:\.self) { type in
                        HStack {
                            VStack {
                                type.textValue
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if let value = profile.lastInbody?.getValueByType(type: type) {
                                    HStack {
                                        Text(String(format:type.formatString,value))
                                            .bold()
                                        if let unit = type.unit {
                                            unit.font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                }
                            }
                            .frame(width:80)
                            
                            
                            NavigationLink {
                                DataDetailView(profile: profile, dataType: type, rows: 10)
                            } label: {
                                InbodyChartView(
                                    profile: profile,
                                    dataType: type,
                                    last: nil,
                                    maxCount: 8)
                                .padding(.bottom,10)
                                
                            }
                            
                        }
                        
                    }
                }
            }
            Section {
                NavigationLink {
                    InbodyDataInputView(profile: profile)
                } label: {
                    ImageTextView(image: .init(systemName: "plus.square"), text: .init("add inbody data"))
                }
            }
        }
        .toolbar {
            NavigationLink {
                UpdateProfileView(profile: profile)
            } label: {
                Text("edit profile")
            }
        }
        .navigationTitle(profile.isInvalidated ? Text("deleted profile") : Text(profile.name))
        .onAppear {
#if !targetEnvironment(simulator)
            
            profile.isDeleted { error1 in
                if error1 == nil {
                    InbodyModel.sync(profile: profile) { error2 in
                        self.error = error2
                    }
                } else {
                    self.error = error1
                }
            }
#endif
        }
        .alert(isPresented: $isAlert) {
            .init(
                title: .init("alert"),
                message: .init(error!.localizedDescription),
                dismissButton: .default(.init("confirm"), action: {
                    switch error! {
                    case CustomError.deletedProfile:
                        let id = profile.id
                        let realm = Realm.shared
                        if let obj = realm.object(ofType: ProfileModel.self, forPrimaryKey: id) {
                            realm.beginWrite()
                            realm.delete(obj)
                            try! realm.commitWrite()
                        }
                        presentationMode.wrappedValue.dismiss()
                    default:
                        break
                    }
                })
            )
        }
    }
    
    var body: some View {
        if profile.id.isEmpty {
            deletedView
        } else {
            normalView
        }
    }
}

#Preview {
    ProfileDetailView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
