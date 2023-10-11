//
//  SignInView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI

struct SignInView: View {
    @State var alertMsg:Text? = nil
    @State var isAlert:Bool = false
    @State var isSignin = false
    
    var signinView : some View {
        Group {
            if isSignin {
                Button {
                    if let err = AuthManager.shared.signout() {
                        isAlert = true
                        alertMsg = Text(err.localizedDescription)
                        
                    } else {
                        isSignin = false
                    }
                } label: {
                    Text("signout")
                }
            } else {
                Button {
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess, error in
                        isSignin = AuthManager.shared.isSignined
                        
                    }
                } label: {
                    Text("signin with apple")
                }
                
                Button {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        isSignin = AuthManager.shared.isSignined
                    }
                } label: {
                    Text("signin with google")
                }
                
                Button {
                    AuthManager.shared.startSignInAnonymously { loginSucess, error in
                        isSignin = AuthManager.shared.isSignined
                    }
                } label : {
                    Text("익명 로그인")
                }
            }
        }
    }
    var body: some View {
        VStack {
            signinView
        }
        .onAppear {
            isSignin = AuthManager.shared.isSignined
        }
        
    }
}

#Preview {
    SignInView()
}
