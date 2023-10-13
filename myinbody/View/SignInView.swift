//
//  SignInView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI

struct SignInView: View {
    enum AlertType {
        case alertError
        case signoutAnomymouse
    }

    @State var isAlert:Bool = false
    @State var errorMsg:Text? = nil {
        didSet {
            if errorMsg != nil {
                alertType = .alertError
                isAlert = true
            }
        }
    }
    @State var alertType:AlertType? = nil {
        didSet {
            if alertType != nil {
                isAlert = true
            }
        }
    }
    @State var isSignin = false
    @State var isAnomymouse = false
    
    private func makeImage(image:Image, text:Text)-> some View {
        HStack {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 30)
            text
                .font(.system(size: 15,weight: .bold))
        }
        .shadow(color: .secondary, radius: 10)
        .foregroundColor(.primary)
        .padding(10)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary,lineWidth: 2.0)
        }
        
    }
    
    func checkSignin() {
        isSignin = AuthManager.shared.isSignined
        isAnomymouse = isSignin ? AuthManager.shared.auth.currentUser?.isAnonymous ?? false : false
    }
    var signinView : some View {
        Section {
            if isSignin {
                Button {
                    if AuthManager.shared.auth.currentUser?.isAnonymous == true {
                        alertType = .signoutAnomymouse
                    }
                    else if let err = AuthManager.shared.signout() {
                        errorMsg = Text(err.localizedDescription)                        
                    }
                    checkSignin()
                    
                } label: {
                    makeImage(image: .init(systemName: "rectangle.portrait.and.arrow.forward"),
                              text: Text("signout"))
                }
                if isAnomymouse {
                    Button {
                        AuthManager.shared.upgradeAnonymousWithAppleId { isSucess, error in
                            if let err = error {
                                errorMsg = Text(err.localizedDescription)
                            }
                            checkSignin()
                        }
                    } label: {
                        makeImage(image: .init(systemName: "apple.logo"),
                                  text: .init("signin with Apple"))
                    }
                    Button {
                        AuthManager.shared.upgradeAnonymousWithGoogleId { isSucess, error in
                            if let err = error {
                                errorMsg = Text(err.localizedDescription)
                            }
                            checkSignin()
                        }
                    } label: {
                        makeImage(image: .init("btn_google_normal"),
                                  text: .init("signin with Google"))
                    }
                                        
                }
               
            } else  {
                Button {
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess, error in
                        checkSignin()
                        
                    }
                } label: {
                    makeImage(image: .init(systemName: "apple.logo"),
                              text: .init("signin with Apple"))
                }
                
                Button {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        checkSignin()
                    }
                } label: {
                    makeImage(image: .init("btn_google_normal"),
                              text: .init("signin with Google"))
                }
                
                Button {
                    AuthManager.shared.startSignInAnonymously { loginSucess, error in
                        checkSignin()
                    }
                } label : {
                    makeImage(
                        image: .init(systemName: "person.fill.questionmark"),
                        text: .init("singin anomymouse")
                    )
                }
                
            }
        }
    }
    var body: some View {
        List {
            Section {
                if isSignin {
                    HStack {
                        Text("ID :").fontWeight(.bold)
                        Text(AuthManager.shared.userId!)
                    }
                }
                signinView
            }
//            if isSignin {
//                ProfileListView()
//            }
        }.listStyle(.automatic)
        .navigationTitle(Text("signin"))
        .onAppear {
            checkSignin()
        }
        .alert(isPresented: $isAlert) {
            switch alertType {
            case .alertError:
                return .init(title: .init("alert"), message: errorMsg)
            case .signoutAnomymouse:
                return .init(
                    title: .init("anomymouse signout title"),
                    message: .init("anomymouse signout msg"),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text("confirm"), action: {
                        if let err = AuthManager.shared.signout() {
                            errorMsg = .init(err.localizedDescription)
                        }
                        checkSignin()
                    })
                )
            case nil:
                abort()
            }
            
        }
    }
}

#Preview {
    SignInView()
}



