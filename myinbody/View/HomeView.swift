//
//  HomeView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import SwiftUI

struct HomeView: View {
    @State var isSignin = false
    var body: some View {
        VStack {
            if isSignin {
                ProfileListView()                
            } else {
                NavigationLink {
                    SignInView()
                } label: {
                    Text("signin")
                }
                
            }
        }
        .navigationTitle(Text("home"))
        .onAppear {
            isSignin = AuthManager.shared.isSignined
        }
    }
    
}

#Preview {
    HomeView()
}
