//
//  CreateProfileView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import SwiftUI
import RealmSwift

struct CreateProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var name:String = ""
    
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
            HStack {
                Text("name")
                TextField("name input", text: $name)
            }
            Button {
                let value = [
                    "name":name
                ]
                ProfileModel .create(value: value) { error in
                    self.error = error
                    if error == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } label: {
                ImageTextView(image: .init(systemName: "square.and.pencil"), text: .init("create"))
            }

        }
        .navigationTitle(Text("add people"))
        .alert(isPresented:$isAlert) {
            return .init(title: Text("alert"),
                  message: Text(error!.localizedDescription))

        }
         
    }
}

#Preview {
    CreateProfileView()
}
