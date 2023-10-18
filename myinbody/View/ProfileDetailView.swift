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

    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    var body: some View {
        List {
            ProfileImageView(profile: profile, size: .init(width: 150, height: 150))
            
            NavigationLink {
                InbodyDataInputView(profile: profile)
            } label: {
                ImageTextView(image: .init(systemName: "plus.square"), text: .init("add inbody data"))
            }
            ForEach(profile.inbodys, id:\.self) { data in
                Text(data.measurementDateTime.formatted())
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
        .onAppear {
            InbodyModel.sync(profile: profile) { error in
                self.error = error
            }
        }
        .alert(isPresented: $isAlert) {
            .init(
                title: .init("alert"),
                message: .init(error?.localizedDescription ?? ""))
        }
    }
}

#Preview {
    ProfileDetailView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
