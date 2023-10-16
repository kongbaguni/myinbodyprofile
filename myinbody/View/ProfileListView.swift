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
            keyPath: "regDtTimeIntervalSince1970"
            ,ascending: true
        )
    ) var profiles

    var body: some View {
        List {
            ForEach(profiles, id:\.self) { profile in
                
                NavigationLink {
                    ProfileDetailView(profile: profile)
                } label: {
                    Text(profile.name)
                }
            }
            .onDelete(perform: { indexSet in
                var deletedCount = 0
                for idx in indexSet {
                    let profile = profiles[idx]
                    profile.delete(removeWithLocal: true) { error in
                        deletedCount += 1
                        $profiles.remove(profile)
                        if deletedCount == indexSet.count {
                            print("delete complete!")
                        }
                    }
                }
            })
            NavigationLink {
                CreateProfileView()
            } label: {
                ImageTextView(
                    image: .init(systemName: "plus.circle"),
                    text: .init("add people"))                
            }
        }
        .navigationTitle(Text("profiles"))
        .toolbar {
            EditButton()
        }
        .onAppear {
            ProfileModel.sync { error in
                
            }
        }
    }
}

#Preview {
    ProfileListView()
}
