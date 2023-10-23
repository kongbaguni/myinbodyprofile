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

    var body: some View {
        List {
            ForEach(profiles, id:\.self) { profile in
                NavigationLink {
                    ProfileDetailView(profile: profile)
                } label: {
                    HStack {
                        ProfileImageView(profile: profile, size: .init(width: 50, height: 50))
                        VStack {
                            Text(profile.name)
                            if let inbody = profile.inbodys.last {
                                HStack {
                                    Text("weight :")
                                        .foregroundStyle(.secondary)
                                    Text(String(format: "%0.0f kg", inbody.weight))
                                }
                                HStack {
                                    Text("BMI :")
                                        .foregroundStyle(.secondary)
                                    Text(String(format: "%0.1f", inbody.bmi))
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
//        .navigationTitle(Text("profiles"))
        .onAppear {
            ProfileModel.sync { error in
                
            }
        }
    }
}

#Preview {
    ProfileListView()
}
