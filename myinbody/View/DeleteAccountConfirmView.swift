//
//  DeleteAccountConfirmView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/1/23.
//

import SwiftUI
import RealmSwift

struct DeleteAccountConfirmView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var confirmTxt:String = ""
    @State var disabledConfirm:Bool = true
    @State var deleteAccountProgress:(title:Text,completed:Int,total:Int)? = nil
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    var confirmTestString:String {
        AuthManager.shared.auth.currentUser?.email ?? "delete account"
    }
    
    var body: some View {
        Group {
            if let p = deleteAccountProgress {
                VStack {
                    p.title
                    ProgressView(
                        value: CGFloat(p.completed),
                        total: CGFloat(p.total))
                    
                }
            } else {
                List {
                    
                    Image(systemName: "person.slash.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(50)
                        .foregroundStyle(.primary, .secondary, .secondary)
                    Text("delete account desc")
                        .foregroundStyle(.secondary)
                    
                    Section {
                        Text("delete account desc2")
                            .foregroundStyle(.secondary)
                        Text(confirmTestString)
                        TextField(
                            text: $confirmTxt,
                            prompt: .init(confirmTestString)) {
                                Text(confirmTestString)
                            }
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: confirmTxt) { oldValue, newValue in
                                disabledConfirm = newValue != confirmTestString
                            }
                            .foregroundColor(disabledConfirm ? .red : .blue)
                        
                        Button {
                            confirmTxt = ""
                            AuthManager.shared.leave { progress in
                                deleteAccountProgress = progress
                            } complete: { error in
                                self.error = error
                                if error == nil {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                        } label: {
                            ImageTextView(image: .init(systemName: "return"), text:.init("confirm"))
                        }
                        .disabled(disabledConfirm)
                    }
                    
                }.navigationTitle(.init("delete account"))
                    .onAppear {
#if DEBUG
                        confirmTxt = confirmTestString
#endif
                    }
            }
        }
        .alert(isPresented: $isAlert, content: {
            .init(
                title: .init("alert"),
                message: .init(error?.localizedDescription ?? ""),
                dismissButton: .default(.init("confirm"), action: {
                    
                    switch error as? CustomError {
                    case .wrongAccountSigninWhenLeave:
                        let realm = Realm.shared
                        realm.beginWrite()
                        realm.deleteAll()
                        try! realm.commitWrite()
                        presentationMode.wrappedValue.dismiss()
                        
                    default:
                        break
                    }
                    
                })
            )
            
        })
            
        
    }
}

#Preview {
    NavigationView {
        NavigationStack {
            DeleteAccountConfirmView()
        }
    }
}
