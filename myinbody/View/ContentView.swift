//
//  ContentView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationStack {
                HomeView()
                    .toolbar {
                        NavigationLink {
                            SignInView()
                        } label: {
                            Image(systemName: "person.fill")
                        }
                        
                    }

            }
        }
        
    }
}

#Preview {
    ContentView()
}
