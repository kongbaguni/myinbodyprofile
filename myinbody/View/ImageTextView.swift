//
//  ImageTextView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI

struct ImageTextView: View {
    let image:Image
    let text:Text
    var body: some View {
        HStack(alignment:.center) {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue,.orange,.red)
                
            text
                .font(.system(size: 20, weight: .bold))            
        }
    }
}

#Preview {
    ImageTextView(
        image: .init(systemName: "memories.badge.plus"),
        text: .init("plus")
    )
}
