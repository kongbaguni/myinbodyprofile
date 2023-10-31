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
    let focusWhenAppear:Bool
    @Binding var value:String
    @FocusState var focused:Bool
    var body: some View {
        HStack {
            title
            TextField(text: $value, prompt: placeHolder) {
                Text("!!")
            }
            .textFieldStyle(.roundedBorder)
            .focused($focused)
        }
        .onAppear {
            if focusWhenAppear {
                focused = true
            }
        }
    }
}

#Preview {
    TitleTextFieldView(title: .init("name"),
                       placeHolder: Text("name input"),
                       focusWhenAppear: true,
                       value: .constant(""))
}
