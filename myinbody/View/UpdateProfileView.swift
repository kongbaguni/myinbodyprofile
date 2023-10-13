//
//  UpdatePeopleView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift

struct UpdateProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedRealmObject var profile:ProfileModel
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    @State var isEdited:Bool = false
    var body: some View {
        List {            
            TitleTextFieldView(
                title: .init("name"),
                placeHolder: .init("input name"),
                value: $profile.name)
            Button {
                isEdited = true
                profile.updateFirestore { error in
                    if error == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                    self.error = error
                }
            } label: {
                ImageTextView(image: .init(systemName: "return"),
                              text:
                        Text("confirm"))
            }
        }
        .onDisappear {
            //편집 컨펌 없으면 서버에서 직전 데이터 가져온다.
            if isEdited == false {
                profile.downloadFirestore { error in
                    
                }
            }
        }
        .navigationTitle(Text("edit"))
        .alert(isPresented: $isAlert)  {
            Alert(title: .init("alert"),
                  message: Text(error!.localizedDescription))
        }
    }
}

#Preview {
    UpdateProfileView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
