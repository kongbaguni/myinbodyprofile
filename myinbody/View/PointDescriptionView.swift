//
//  PointDescriptionView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/14/23.
//

import SwiftUI

struct PointDescriptionView: View {
    let ad = GoogleAd()
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
            Image(systemName: "questionmark.diamond")
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundStyle(.yellow,.orange,.blue)
            Text("Point Description 1")
            Text("Point Description 2")
            Text("Point Description 3")
            
            Button {
                ad.showAd { error in
                    self.error = error
                }
            } label : {
                ImageTextView(
                    image: .init(systemName: "sparkles.tv"),
                    text: .init("ad watch"))
            }

        }
        .listStyle(.plain)
        .navigationTitle(Text("Point Description title"))
        .alert(isPresented: $isAlert) {
            
            return .init(title: .init("alert"),
                         message: .init(error?.localizedDescription ?? "")
            )
            
        }

    }
}

#Preview {
    PointDescriptionView()
}
