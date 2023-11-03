//
//  ProfileListView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import SwiftUI
import RealmSwift

struct ProfileListView: View {
    @ObservedResults(
        ProfileModel .self,
        sortDescriptor: .init(
            keyPath: "name"
            ,ascending: true
        )
    ) var profiles

    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    
    @State var isAlert:Bool = false
    
    var body: some View {
        List {
            if profiles.count == 0 {
                Section {
                    Image("launchIcon")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
            }
            
            ForEach(profiles, id:\.self) { profile in
                NavigationLink {
                    ProfileDetailView(profile: profile)
                } label: {
                    HStack {
                        ProfileImageView(profile: profile, size: .init(width: 150, height: 150), drawRound: true)
                        VStack(alignment: .leading) {
                            Text(profile.name)
                                .font(.system(size: 18))
                                .bold()
                            if let inbody = profile.inbodys.last {
                                Divider()

                                HStack {
                                    Text("weight :")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 12))
                                    Text(String(format: "%0.0f", inbody.weight))
                                        .font(.system(size: 18, weight: .heavy))
                                    Text("kg")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 12))
                                }
                                
                                HStack {
                                    Text("inbody point :")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 12))
                                    Text(String(format: "%0.0f", inbody.inbodyPoint))
                                        .font(.system(size: 18, weight: .heavy))
                                }
                                
                                HStack {
                                    Text("BMI :")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 12))
                                    Text(String(format: "%0.1f", inbody.bmi))
                                        .font(.system(size: 18, weight: .heavy))
                                }
                            }
                        }
                    }
                }
            }
            NavigationLink {
                CreateProfileView()
            } label: {
                ImageTextView(
                    image: .init(systemName: "plus.circle"),
                    text: .init("add people"))                
            }
        }
        .onAppear {
            ProfileModel.sync { error in
                
            }
        }
        .alert(isPresented: $isAlert) {
            .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        }
    }
}

#Preview {
    ProfileListView()
}
