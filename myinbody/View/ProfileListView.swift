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
        ProfileModel.self,
        sortDescriptor: .init(
            keyPath: "name"
            ,ascending: true
        )
    ) var profiles

    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    
    @State var isAlert:Bool = false
    
    @State var profileCount = 0
    
    var profileList : some View {
        ForEach(profiles, id:\.self) { profile in
            NavigationLink {
                ProfileDetailView(profile: profile)
            } label: {
                HStack {
                    ProfileImageView(profile: profile, size: .init(width: 150, height: 150), drawRound: true)
                    VStack(alignment: .leading) {
                        Text(profile.name)
                            .font(.system(size: 18))
                            .bold()
                        if let inbody = profile.inbodys.filter("deleted = %@", false).last {
                            Divider()
                            
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
                                Text("inbody point :")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 12))
                                Text(String(format: "%0.0f", inbody.inbodyPoint))
                                    .font(.system(size: 18, weight: .heavy))
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
    }
        
    var body: some View {
        List {
            Section {
                if profileCount == 0 {
                    HStack {
                        Spacer()
                        Image("launchIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .frame(maxHeight: 200)
                        Spacer()
                    }
                } else {
                    profileList
                }
            }
            Section("ad") {
                NativeAdView()
            }
            NavigationLink {
                CreateProfileView()
            } label: {
                ImageTextView(
                    image: .init(systemName: "plus.circle"),
                    text: .init("add people"))                
            }
        }
        .refreshable {
            loadData()
        }
        .onAppear {
            loadData()
        }
        .alert(isPresented: $isAlert) {
            .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
        }
    }
    
    func loadData() {
        ProfileModel.sync { error in
            self.error = error
            if error == nil {
                profileCount = profiles.count
            }
        }
    }
}

#Preview {
    ProfileListView()
}
