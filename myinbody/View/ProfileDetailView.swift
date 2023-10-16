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
        VStack {
            ProfileImageView(profile: profile, size: .init(width: 150, height: 150))
            Text(profile.name)
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
    ProfileDetailView(profile: .init(value: ["id":"test","name":"test","profileImageURL":"https://t3.gstatic.com/licensed-image?q=tbn:ANd9GcRoT6NNDUONDQmlthWrqIi_frTjsjQT4UZtsJsuxqxLiaFGNl5s3_pBIVxS6-VsFUP_"]))
}
