//
//  InbodyDataDeleteConfirmView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/10/23.
//

import SwiftUI
import RealmSwift

struct InbodyDataDeleteConfirmView: View {
    @ObservedRealmObject var inbodyModel:InbodyModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let ad = GoogleAd()
    
    @State var error:Error? = nil {
        didSet {
            isAlert = error != nil
        }
    }
    @State var isAlert:Bool = false
    var body: some View {
        List {
            Section {
                PointNeedView(pointCase: .inbodyDataDelete)
                Text("inbody data delete confirm msg")
            }
            Section {
                Button {
                    delete()
                } label : {
                    ImageTextView(image: .init(systemName: "trash.circle"), text: .init("delete"))
                }
            }
        }
        .navigationTitle(.init("delete"))
        .alert(isPresented: $isAlert, content: {
            switch error as? CustomError {
            case .notEnoughPoint:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? ""),
                    primaryButton: .cancel({
                    }),
                    secondaryButton: .default(.init("ad watch"), action: {
                        ad.showAd { error in
                            if error == nil {
                                delete()
                            }
                            self.error = error
                        }
                    }))
            default:
                return .init(title: .init("alert"), message:.init(error?.localizedDescription ?? ""))
            }
        })
        
    }
    
    func delete() {
        PointModel.use(useCase: .inbodyDataDelete) { error in
            if let err = error {
                self.error = err
            } else {
                inbodyModel.delete { error in
                    self.error = error
                    if error == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    InbodyDataDeleteConfirmView(inbodyModel: .init())
}
