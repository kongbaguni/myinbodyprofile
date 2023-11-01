//
//  TitleTextFieldView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
extension Notification.Name {
    static let textfieldSetFocus = Notification.Name("textfieldSetFocus_observer")
}

struct TitleTextFieldView: View {
    let id:String
    let title:Text
    let placeHolder:Text?
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
        .onReceive(NotificationCenter.default.publisher(for: .textfieldSetFocus)) { noti in
            if id == noti.object as? String {
                focused = true
            }
        }
    }
}

#Preview {
    TitleTextFieldView(
        id:"name",
        title: .init("name"),
        placeHolder: Text("input name"),
        value: .constant(""))
}
