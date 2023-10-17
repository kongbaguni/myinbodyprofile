//
//  ProfileDetailView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift

struct ProfileDetailView: View {
    @ObservedRealmObject var profile:ProfileModel

    
    var body: some View {
        List {
            ProfileImageView(profile: profile, size: .init(width: 150, height: 150))
            
            NavigationLink {
                InbodyDataInputView(profile: profile)
            } label: {
                ImageTextView(image: .init(systemName: "plus.square"), text: .init("add inbody data"))
            }

        }
        .toolbar {
            NavigationLink {
                UpdateProfileView(profile: profile)
            } label: {
                Text("edit profile")
            }
        }
        .navigationTitle(Text(profile.name))
    }
}

#Preview {
    ProfileDetailView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
