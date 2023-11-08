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

    let ad = GoogleAd()
    @State var point:Int = 0
    
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
                    ProfileImageView(profile: profile, size: .init(width: 150, height: 150), drawRound: true)
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
                
                HStack {
                    Text("points needed :").foregroundStyle(.secondary)
                    Text("\(PointModel.PointUseCase.deleteProfile.rawValue)").bold()
                }
                HStack {
                    Text("Current Point :").foregroundStyle(.secondary)
                    Text("\(point)").bold()
                }
                Button {
                    confirm()
                } label: {
                    ImageTextView(image: .init(systemName: "return"),
                                  text: .init("confirm"))
                }
                .disabled(!isTestEnable)
            }
                        
        }
        .onAppear {
            PointModel.sync { error in
                point = PointModel.sum
            }
        }
        
        .navigationTitle("delete profile title")
        .alert(isPresented: $isAlert) {
            switch error as? CustomError {
            case .notEnoughPoint:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? ""),
                    primaryButton: .cancel(),
                    secondaryButton: .default(.init("ad watch"), action: {
                        ad.showAd { isSucess in
                            if isSucess {
                                confirm()
                            }
                        }
                    }))
                
            default:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? "")
                )
            }
        }
        
    }
    
    func confirm() {
        if profile.name != test {
            error = CustomError.incorrectName
            return
        }
        profile.delete(removeWithLocal: true) { error in
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            }
            else {
                self.error = error
            }
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
