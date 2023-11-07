//
//  CacheClearView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/7/23.
//

import SwiftUI
import RealmSwift
fileprivate let iconNames:[String] = [
    "eraser",
    "eraser.line.dashed",
//    "eraser.fill",
//    "eraser.line.dashed.fill",
]

struct CacheClearView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var iconName:String = iconNames.randomElement()!

    @State var isComplete:Bool = false
    func changeIcon() {
        let new = iconNames.randomElement()!
        if iconName == new {
            changeIcon()
            return
        }
        
        iconName = iconNames.randomElement()!
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            changeIcon()
        }
    }
    
    var body: some View {
        List {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundStyle(.primary,.orange,.yellow)
                .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                .frame(height: 300)
            
            Text("clear cache description")
            
            Button {
                do {
                    let realm = Realm.shared
                    realm.beginWrite()
                    realm.deleteAll()
                    try realm.commitWrite()
                    
                } catch {
                    print(error.localizedDescription)
                    return
                }
                isComplete = true
            } label: {
                Text("confirm")
            }
        }
        .onAppear {
            changeIcon()
        }
        .navigationTitle(.init("clear cache"))
        .alert(isPresented: $isComplete, content: {
            .init(title: .init("clear cache"),
                  message: .init("clear chech finish msg"),
                  dismissButton: .default(.init("confirm"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        })
            
    }
}

#Preview {
    NavigationView {
        CacheClearView()
    }
}
