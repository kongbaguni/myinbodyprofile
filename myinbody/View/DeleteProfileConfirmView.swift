//
//  DeleteProfileConfirmView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/27/23.
//

import SwiftUI
import RealmSwift

struct DeleteProfileConfirmView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedRealmObject var profile:ProfileModel

    @State var test:String = ""
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    @State var isTestEnable = false
    
    var body: some View {
        List {
            Section {
                HStack(alignment:.top) {
                    ProfileImageView(profile: profile, size: .init(width: 150, height: 150))
                    Text(profile.name)
                }
                
                Text("delete profile message")
            }
            Section {
                Text("delete profile message2")
                TextField(text: $test) {
                    Text(profile.name)
                }
                .onChange(of: test, { oldValue, newValue in
                    isTestEnable = profile.name.trimmingCharacters(in: .whitespacesAndNewlines) == newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                })
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(isTestEnable ? .blue : .red)
                
                Button {
                    if profile.name != test {
                        error = CustomError.incorrectName
                        return
                    }
                    profile.delete(removeWithLocal: true) { error in
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    ImageTextView(image: .init(systemName: "return"),
                                  text: .init("confirm"))
                }
                .disabled(!isTestEnable)
            }
            
            
        }
        .navigationTitle("delete profile title")
        .alert(isPresented: $isAlert) {
            .init(
                title: .init("alert"),
                message: .init(error?.localizedDescription ?? "")
            )
        }
        
    }
}

#Preview {
    NavigationView {
        NavigationStack {
            DeleteProfileConfirmView(profile: .init(value: ["id":"test","name":"홍길동"]))
        }
    }
}
