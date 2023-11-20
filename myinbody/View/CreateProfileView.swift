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
    let ad = GoogleAd()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var point:Int = 0
    @State var name:String = ""
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var gender:ProfileModel.Gender = .unkonown
    @State var isAlert:Bool = false
    @State var photoData:Data? = nil
    @State var isLoading:Bool = false
    @State var birthday:Date = Date()
    
    private func createProfile() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = CustomError.emptyName
            return
        }
        guard let userId = AuthManager.shared.userId else {
            return
        }
        isLoading = true
        let value:[String:AnyHashable] = [
            "name":name,
            "genderValue":gender.rawValue,
            "birthdayDtTimeIntervalSince1970":birthday.timeIntervalSince1970
        ]
      
        ProfileModel.create(value: value) { profileId, error1 in
            
            if let data = photoData {
                let uploadId = "\(userId)/\(profileId)"
                FirebaseStorageHelper.shared.uploadData(data: data, contentType: .jpeg, uploadPath: .profileImage, id: uploadId) { downloadURL, error2 in
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
                    
                    self.error = error1 ?? error2
                    if error == nil {
                        isLoading = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                self.error = error1
                if error == nil {
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    var body: some View {
        List {
            if isLoading {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment:.center) {
                        Spacer(minLength: 100)
                        ActivityIndicatorView(isVisible: $isLoading, type: .default(count: 10))
                            .frame(width:50,height:50)
                        Text("uploading")
                        Spacer(minLength: 100)
                    }
                    Spacer()
                }
            } else {
                PhotoPickerView(selectedImageData: $photoData, size:.init(width: 150, height: 150), placeHolder: .init(systemName: "person"), profileImageView: nil)
                
                TitleTextFieldView(
                    id:"name",
                    title: .init("name"),
                    placeHolder: .init("input name"),
                    value: $name)
                
                DatePicker("birthday", selection: $birthday, displayedComponents: .date)
                    
                
                Picker("gender", selection: $gender) {
                    ForEach(ProfileModel.Gender.allCases, id:\.self) {
                        $0.textValue
                    }
                }

                PointNeedView(pointCase: .createProfile)
                
                Button {
                    createProfile()
                    
                } label: {
                    ImageTextView(image: .init(systemName: "return"), text: .init("create"))
                }
            }
        }
        .onAppear {
            PointModel.sync { error in
                point = PointModel.sum
            }            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                NotificationCenter.default.post(name: .textfieldSetFocus, object: "name")
            }
        }
        .navigationTitle(Text("add people"))
        .alert(isPresented:$isAlert) {
            switch error as? CustomError {
            case .notEnoughPoint:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? ""),
                    primaryButton: .cancel({
                       isLoading = false
                    }),
                    secondaryButton: .default(.init("ad watch"), action: {
                        ad.showAd { error in
                            if error == nil {
                                createProfile()
                            }
                            else {
                                isLoading = false
                                self.error = error
                            }
                        }
                    }))
                
            case .emptyName:
                return .init(title: .init("alert"),
                             message: .init(error!.localizedDescription),
                             dismissButton: .default(.init("confirm"), action: {
                        NotificationCenter.default.post(name: .textfieldSetFocus, object: "name")
                }))
            default:
                return .init(title: .init("alert"),
                             message: .init(error!.localizedDescription))
            }
        }
         
    }
}

#Preview {
    CreateProfileView()
}
