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
                        VStack(alignment: .leading) {
                            Text(profile.name)
                                .font(.system(size: 18))
                                .bold()
                            if let inbody = profile.inbodys.last {
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
