//
//  CreateProfileView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/12/23.
//

import SwiftUI
import RealmSwift
import ActivityIndicatorView

struct CreateProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>    
    @State var name:String = ""
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    
    @State var isAlert:Bool = false
    @State var photoData:Data? = nil
    @State var isLoading:Bool = false
    
    private func createProfile(profileId:String? = nil) {
        guard let userId = AuthManager.shared.userId else {
            return
        }
        isLoading = true
        let value = [
            "name":name
        ]
        let profileId = profileId ?? "\(UUID().uuidString):\(Date().timeIntervalSince1970)"
        if let data = photoData {
            let uploadId = "\(userId)/\(profileId)"
            FirebaseStorageHelper.shared.uploadData(data: data, contentType: .jpeg, uploadPath: .profileImage, id: uploadId) { downloadURL, error in
                if let url = downloadURL {
                    if let err = FirestorageDownloadUrlCacheModel.reg(id: uploadId, url: url.absoluteString) {
                        self.error = err
                        return
                    }
                }
                if let err = error {
                    self.error = err
                    return
                }
                photoData = nil
                createProfile(profileId: profileId)
            }
            return
        }
        ProfileModel.create(documentId: profileId, value: value) { error in
            self.error = error
            if error == nil {
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var body: some View {
        Group {
            if isLoading {                
                VStack(alignment:.center) {
                    ActivityIndicatorView(isVisible: $isLoading, type: .default(count: 10))
                        .frame(width:50,height:50)
                    Text("uploading")
                }
            } else {
                List {
                    PhotoPickerView(selectedImageData: $photoData, size:.init(width: 150, height: 150))
                    if photoData != nil {
                        Button {
                            photoData = nil
                        } label: {
                            ImageTextView(image: .init(systemName: "trash.circle"), text: Text("cancel photo upload"))
                        }
                    }
                    
                    TitleTextFieldView(title: .init("name"),
                                       placeHolder: .init("name input"), value: $name)
                    
                    Button {
                        createProfile()
                        
                    } label: {
                        ImageTextView(image: .init(systemName: "return"), text: .init("create"))
                    }
                }
            }
        }
        .navigationTitle(Text("add people"))
        .alert(isPresented:$isAlert) {
            return .init(title: Text("alert"),
                  message: Text(error!.localizedDescription))

        }
         
    }
}

#Preview {
    CreateProfileView()
}
