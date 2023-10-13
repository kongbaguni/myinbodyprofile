//
//  TitleTextFieldView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI

struct TitleTextFieldView: View {
    let title:Text
    let placeHolder:Text?
    @Binding var value:String
    var body: some View {
        HStack {
            title
            TextField(text: $value, prompt: placeHolder) {
             Text("!!")
            }
            .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    TitleTextFieldView(title: .init("name"),
                       placeHolder: Text("name input"),
                       value: .constant(""))
}
