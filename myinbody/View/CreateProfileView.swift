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
    @State var photoData:Data? = nil
    
    var body: some View {
        List {
            PhotoPickerView(selectedImageData: $photoData)
            TitleTextFieldView(title: .init("name"),
                               placeHolder: .init("name input"), value: $name)
            
            Button {
                let value = [
                    "name":name
                ]
                if let data = photoData {
                    
                }
                ProfileModel.create(value: value) { error in
                    self.error = error
                    if error == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
            } label: {
                ImageTextView(image: .init(systemName: "return"), text: .init("create"))
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
