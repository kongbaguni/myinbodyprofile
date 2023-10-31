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
    @State var profileImageUrl:String? = nil
    
    var placeholder : some View {
        Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .padding(10)
            .backgroundStyle(.gray)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.primary, lineWidth: 2)
            }
            .frame(width:size.width,height: size.height)
    }
    
    var body: some View {
        Group {
            if let url = profileImageUrl {
                CachedAsyncImage(url: .init(string:url)) { image in
                    image.resizable()
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 2)
                        }
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
        .onAppear {
            #if !targetEnvironment(simulator)
            profileImageUrl = profile.profileImageURL
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .profileImageUpdated, object: nil), perform: { noti in
            if let url = noti.object as? URL {
                profileImageUrl = url.absoluteString
            }
            if let url = noti.userInfo?["url"] as? URL, let id = noti.userInfo?["id"] as? String {
                if profile.profileImageId == id {
                    profileImageUrl = url.absoluteString
                }
            }
        })
        
    }
}

#Preview {
    ProfileImageView(profile: .init(value: ["id":"test","name":"홍길동"]), size: .init(width: 100, height: 100))
}
