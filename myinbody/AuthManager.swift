//
//  AuthManager.swift
//  PixelArtMaker
//
//  Created by Changyeol Seo on 2022/03/17.
//

import Foundation
import CryptoKit
import AuthenticationServices
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import RealmSwift

extension Notification.Name {
    static let authDidSucessed = Notification.Name("authDidSucessed_observer")
    static let signoutDidSucessed = Notification.Name("signoutDidSucessed_observer")
}

class AuthManager : NSObject {
    static let shared = AuthManager()
    let auth = Auth.auth()
    var appleReAuth = false
    var userId:String? {
        return auth.currentUser?.uid
    }
    
    
    var isSignined:Bool {
        return auth.currentUser != nil
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    fileprivate var didComplete:(_ loginSucess:Bool, _ error: Error?)->Void = { _ , _ in }
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    //MARK: - 구글 아이디로 로그인하기
    func startSignInWithGoogleId(complete:@escaping(_ loginSucess:Bool, _ error:Error? )->Void) {
        didComplete = complete
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let vc = UIApplication.shared.rootViewController
        else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
            
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                complete(false, error)
                return
            }
            
            
            guard
                let accessToken = result?.user.accessToken,
                let idToken = result?.user.idToken
            else {
                return
            }
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            
            print(credential)
            Auth.auth().signIn(with: credential) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    complete(false, err)
                    return
                }
                complete(true, nil)
                if error == nil {
                    NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                }
            }
        }
    }
    
    //MARK: - 애플 아이디로 로그인하기
    func startSignInWithAppleFlow(complete:@escaping(_ loginSucess:Bool, _ error:Error?)->Void) {
        didComplete = complete
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - 익명 로그인
    func startSignInAnonymously(complete:@escaping(_ loginSucess:Bool, _ error:Error?)->Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if let err = error {
                print("error : \(err.localizedDescription)")
                complete(false, err)
                return
            }
            complete(true,nil)
            if error == nil {
                NotificationCenter.default.post(name: .authDidSucessed, object: nil)
            }
        }
    }
    //MARK: - 로그아웃
    func signout()->Error? {
        do {
            if auth.currentUser?.isAnonymous == true {
                auth.currentUser?.delete()
            }
            let realm = Realm.shared
            realm.beginWrite()
            realm.deleteAll()
            try realm.commitWrite()
            try auth.signOut()
        } catch {
            return error
        }
        return nil
    }

    //MARK: - 탈퇴하기
    func leave(progress:@escaping(_ progress:(title:Text,completed:Int,total:Int))->Void, complete:@escaping(_ error:Error?)->Void) {
        
        let leaveUserID = AuthManager.shared.userId
        func reauth(complete:@escaping(_ error:Error?)->Void) {
            switch auth.currentUser?.providerData.first?.providerID {
            case "google.com":
                print("구글 이다")
                startSignInWithGoogleId { loginSucess , error in
                    let err = AuthManager.shared.userId != leaveUserID ? CustomError.wrongAccountSigninWhenLeave : error
                    complete(err)
                }
            case "apple.com":
                appleReAuth = true
                startSignInWithAppleFlow { loginSucess, error  in
                    self.appleReAuth = false
                    let err = AuthManager.shared.userId != leaveUserID ? CustomError.wrongAccountSigninWhenLeave : error
                    complete(err)
                }
                print("애플 이다")
            default:
                print("모르겠다")
            }
        }
        
        func deleteAccount(complete:@escaping(_ error:Error?)-> Void) {
            auth.currentUser?.delete(completion: { error in
                complete(error)
            })
        }
        
        func deleteInbodyData(complete:@escaping(_ error:Error?)-> Void) {
            let inbodyDatas = Realm.shared.objects(InbodyModel.self)
            let dataCount = inbodyDatas.count
            var count = 0
            if dataCount == 0 {
                complete(nil)
                return
            }
            for inbody in inbodyDatas {
                inbody.delete { error in
                    if error == nil {
                        count += 1
                        DispatchQueue.main.async {
                            progress((title:.init("delete inbody data..."),completed:count,total:dataCount))
                        }
                        if count == dataCount {
                            complete(nil)
                        }
                    }
                    else {
                        complete(error)
                    }
                }
            }
        }
        
        func deleteProfileData(complete:@escaping(_ error:Error?)-> Void) {
            let profileDatas = Realm.shared.objects(ProfileModel.self)
            let profileCount = profileDatas.count
            if profileCount == 0 {
                complete(nil)
                return
            }

            var count = 0
            for profile in profileDatas {
                profile.delete { error in
                    if error == nil {
                        count += 1
                        DispatchQueue.main.async {
                            progress((title:.init("delete inbody data..."),completed:count,total:profileCount))
                        }
                        if count == profileCount {
                            complete(nil)
                        }
                            
                    }
                    else {
                        complete(error)
                    }
                }
            }
            
        }
        reauth { error in
            if error == nil {
                deleteInbodyData { errorB in
                    deleteProfileData { errorC in
                        if errorB == nil && errorC == nil {
                            deleteAccount { error in
                                if error == nil {
                                    let realm = Realm.shared
                                    realm.beginWrite()
                                    realm.deleteAll()
                                    try! realm.commitWrite()
                                }
                                complete(error)
                            }
                            return
                        }
                        complete(errorB ?? errorC)
                    }
                }
            }
            else {
                complete(error)
            }
        }
    }

    
    func upgradeAnonymousWithGoogleId(complete:@escaping(_ isSucess:Bool, _ error:Error?)->Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let vc = UIApplication.shared.rootViewController
        else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
            
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [unowned self] result, error  in
            guard
                let accessToken = result?.user.accessToken.tokenString,
                let idToken = result?.user.idToken?.tokenString
            else {
              return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            auth.currentUser?.link(with: credential, completion: { result, error in
                if error == nil {
                    NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                }
                complete(error == nil, error)
            })
        }
    }
    
    func upgradeAnonymousWithAppleId(complete:@escaping(_ isSucess:Bool, _ error:Error?)->Void) {
        startSignInWithAppleFlow(complete: complete)
    }
}


extension AuthManager : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return .init()
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            if auth.currentUser == nil || appleReAuth {
                // Sign in with Firebase.
                auth.signIn(with: credential) { [self] (authResult, error) in
                    if let error = error {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error.localizedDescription)
                        didComplete(false, error)
                        return
                    }
                    print("login sucess")
                    didComplete(true, nil)
                    print(authResult?.user.email ?? "없다")
                    NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                    // User is signed in to Firebase with Apple.
                    // ...
                }
            } else {
                auth.currentUser?.link(with: credential, completion: { [unowned self] result, error in
                    didComplete(error == nil, error)
                    if error == nil {
                        NotificationCenter.default.post(name: .authDidSucessed, object: nil)
                    }
                })
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
