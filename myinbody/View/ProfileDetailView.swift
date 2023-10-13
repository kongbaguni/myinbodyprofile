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
            if profile.profileImageURL.isEmpty == false {
                AsyncImage(url: .init(string: profile.profileImageURL)) { image in
                    image.image?
                        .resizable()
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth:2)
                        }
                        .shadow(color:.secondary,radius: 10)
                    
                }
                .scaledToFill()
                .frame(width:100,height: 100)
            }
            else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFill()
                    .frame(width:100,height: 100)
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
