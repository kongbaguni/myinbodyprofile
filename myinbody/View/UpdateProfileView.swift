//
//  UpdatePeopleView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift

struct UpdateProfileView: View {
    @ObservedRealmObject var profile:ProfileModel
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    UpdateProfileView(profile: .init())
}
