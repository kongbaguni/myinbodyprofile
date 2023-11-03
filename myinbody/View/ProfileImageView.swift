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
    let drawRound:Bool

    @State var profileImageUrl:String? = nil
    
    var placeholder : some View {
        Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .padding(10)
            .backgroundStyle(.gray)
            .overlay {
                RoundedRectangle(cornerRadius: drawRound ? 10 : 0)
                    .stroke(.primary, lineWidth: drawRound ? 2 : 0)
            }
            .frame(width:size.width,height: size.height)
    }
    
    var body: some View {
        Group {
            if let url = profileImageUrl {
                CachedAsyncImage(url: .init(string:url)) { image in
                    image.resizable()
                        .cornerRadius(drawRound ? 10 : 0)
                        .overlay {
                            RoundedRectangle(cornerRadius: drawRound ? 10 : 0)
                                .stroke(Color.primary, lineWidth: drawRound ? 2 : 0)
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
    ProfileImageView(profile: .init(value: ["id":"test","name":"홍길동"]), size: .init(width: 100, height: 100),drawRound: true)
}
