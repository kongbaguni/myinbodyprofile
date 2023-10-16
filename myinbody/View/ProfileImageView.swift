//
//  ProfileImageView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/16/23.
//

import SwiftUI
import RealmSwift
import CachedAsyncImage

struct ProfileImageView: View {
    @ObservedRealmObject var profile:ProfileModel
    let size:CGSize
    
    var placeholder : some View {
        Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .frame(width:size.width,height: size.height)
    }
    
    var body: some View {
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
                    .frame(width:size.width,height: size.height)
            } placeholder: {
                placeholder
            }
        }
        else {
            placeholder
        }
        
    }
}

#Preview {
    ProfileImageView(profile: .init(value: ["id":"test","name":"홍길동"]), size: .init(width: 100, height: 100))
}
