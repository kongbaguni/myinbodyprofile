//
//  ProfileDetailView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct ProfileDetailView: View {
    @ObservedRealmObject var profile:ProfileModel

    var placeholder : some View {
        Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .frame(width:100,height: 100)
    }
    
    var body: some View {
        VStack {
            if let url = profile.profileImageURL {
                CachedAsyncImage(url: .init(string:url)) { image in
                    image.resizable()
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 2)
                        }
                        .shadow(color:.secondary,radius: 10)
                        .scaledToFill()
                        .frame(width:100,height: 100)
                } placeholder: {
                    placeholder
                }
            }
            else {
                placeholder
            }
            
            Text(profile.name)
        }
        .toolbar {
            NavigationLink {
                UpdateProfileView(profile: profile)
            } label: {
                Text("edit")
            }
        }
        .navigationTitle(Text(profile.name))
    }
}

#Preview {
    ProfileDetailView(profile: .init(value: ["id":"test","name":"test","profileImageURL":"https://t3.gstatic.com/licensed-image?q=tbn:ANd9GcRoT6NNDUONDQmlthWrqIi_frTjsjQT4UZtsJsuxqxLiaFGNl5s3_pBIVxS6-VsFUP_"]))
}
