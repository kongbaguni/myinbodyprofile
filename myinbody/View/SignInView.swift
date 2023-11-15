//
//  SignInView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/11/23.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    enum AlertType {
        case alertError
        case signoutAnomymouse
    }
    let ad = GoogleAd()
        
    @State var point:Int = PointModel.sum
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    
    @State var alertType:AlertType? = nil {
        didSet {
            if alertType != nil {
                isAlert = true
            }
        }
    }
    @State var isSignin = false
    @State var isAnomymouse = false
//    @State var currentUser:User? = nil
    
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
//        currentUser = AuthManager.shared.auth.currentUser
        isSignin = AuthManager.shared.isSignined
        isAnomymouse = isSignin ? AuthManager.shared.auth.currentUser?.isAnonymous ?? false : false
        if isSignin {
            PointModel.initPoint { errorB in
                self.error = errorA ?? errorB
            }
        }
    }
    
    var signinView : some View {
        Section {
            if isSignin {
                NavigationLink {
                    PointHistoryView()
                } label: {
                    HStack {
                        Text("Point :").foregroundStyle(.secondary)
                        Text("\(point)").bold()
                    }
                }

                Button {
                    ad.showAd { error in
                        self.error = error
                    }
                } label : {
                    ImageTextView(
                        image: .init(systemName: "sparkles.tv"),
                        text: .init("ad watch"))
                }
                Button {
                    if AuthManager.shared.auth.currentUser?.isAnonymous == true {
                        alertType = .signoutAnomymouse
                    }
                    else if let err = AuthManager.shared.signout() {
                        self.error = err
                    }
                    checkSignin()
                    
                } label: {
                    ImageTextView(image: .init(systemName: "rectangle.portrait.and.arrow.forward"),
                                  text: .init("signout"))
                }
                if isAnomymouse {
                    Button {
                        AuthManager.shared.upgradeAnonymousWithAppleId { isSucess, error in
                            self.error = error
                            checkSignin()
                        }
                    } label: {
                        makeImage(image: .init(systemName: "apple.logo"),
                                  text: .init("continue with Apple"))
                    }
                    Button {
                        AuthManager.shared.upgradeAnonymousWithGoogleId { isSucess, error in
                            self.error = error
                            checkSignin()
                        }
                    } label: {
                        makeImage(image: .init("btn_google_normal"),
                                  text: .init("continue with Google"))
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
    
    func makeRow(left:Text,right:some View)->some View {
        HStack {
            left
                .foregroundStyle(Color.secondary)
            right
        }
    }
    
    func makeText(left:Text,right:String)->some View {
        makeRow(
            left: left,
            right: Text(right)
                .foregroundStyle(Color.primary)
                .fontWeight(.bold)
        )
    }
    
    func makeWebviewLink(fileName:String, title:Text) -> some View {
        Group {
            if let url = Bundle.main.url(forResource: "HTML/\(fileName)", withExtension: "html") {
                NavigationLink {
                    WebView(url: url, title: title)
                } label: {
                    title
                }
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                if isSignin {
                    if let user = AuthManager.shared.auth.currentUser {
                        makeText(left: .init("id :"), right: user.uid)
                        if let date = user.metadata.lastSignInDate {
                            makeText(left: .init("last signin date :"), right: date.formatted(date: .numeric, time: .shortened))
                        }
                        if let date = user.metadata.creationDate {
                            makeText(left: .init("creation date :"), right: date.formatted(date: .numeric, time: .shortened))
                        }
                        if let value = user.email {
                            makeText(left: .init("Email :"), right: value)
                        }
                        if let value = user.displayName {
                            makeText(left: .init("name :"), right: value)
                        }
                        if let value = user.phoneNumber {
                            makeText(left: .init("phone :"), right: value)
                        }
                        if let value = user.photoURL {
                            makeRow(
                                left: .init("profile image :"),
                                right: AsyncImage(url: value) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100,height: 100)
                                    
                                } placeholder: {
                                    Image(systemName: "person")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100,height: 100)
                                }
                            )
                        }
                            
                    }
                    
                }
                signinView
            }
            
            Section {
                makeWebviewLink(fileName: "openSourceLicense", title:.init("OpenSource License"))
                makeWebviewLink(fileName: "term", title: .init("term"))
                makeWebviewLink(fileName: "privacyPolicy", title: .init("privacy policy"))
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    HStack {
                        Text("App Version :")
                            .foregroundStyle(.secondary)
                        Text(appVersion)
                            .foregroundStyle(.primary)                    
                        
                    }
                }
            }
            Section {
                NavigationLink {
                    CacheClearView()
                } label: {
                    ImageTextView(image: .init(systemName: "eraser.line.dashed"), text: .init("clear cache"))
                }
            }
            if !isAnomymouse && isSignin {
                Section {
                    NavigationLink {
                        DeleteAccountConfirmView()
                    } label: {
                        ImageTextView(image: .init(systemName:"person.slash.fill"), text: .init("delete account"))
                    }
                }
            }
        }
        .listStyle(.automatic)
        .navigationTitle(isSignin ? Text("signin info") : Text("signin"))
        .onAppear {
//            currentUser = AuthManager.shared.auth.currentUser
            checkSignin()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pointDidChanged), perform: { noti in
            point = noti.object as? Int ?? PointModel.sum
        })
        .alert(isPresented: $isAlert) {
            switch alertType {
            case .alertError:
                return .init(title: .init("alert"), message: .init(error?.localizedDescription ?? ""))
            case .signoutAnomymouse:
                return .init(
                    title: .init("anomymouse signout title"),
                    message: .init("anomymouse signout msg"),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text("confirm"), action: {
                        if let err = AuthManager.shared.signout() {
                            self.error = err
                        }
                        checkSignin()
                    })
                )
            default:
                return .init(title: .init("alert"),
                             message: .init(error?.localizedDescription ?? "")
                )
            }
            
        }
    }
}

#Preview {
    SignInView()
}



