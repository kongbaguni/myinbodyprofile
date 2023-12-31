//
//  UpdatePeopleView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import RealmSwift
import ActivityIndicatorView


struct UpdateProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let ad = GoogleAd()
    @ObservedRealmObject var profile:ProfileModel
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    @State var isEdited:Bool = false
    @State var photoData:Data? = nil
    @State var needDeletePhoto:Bool = false
    @State var deleteAlert:Bool = false
    @State var gender:ProfileModel.Gender = .unkonown
    @State var name:String = ""
    @State var birthday:Date = .init(timeIntervalSince1970: 0)
    func saveWithPointUse() {
        PointModel.use(useCase: .editProfile) { error in
            if error == nil {
                updateProfile()
            }
            self.error = error
        }
    }
    
    func updateProfile() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = CustomError.emptyName
            return
        }

        isEdited = true
        guard let profileImageId = profile.profileImageId else {
            return
        }
        
        if needDeletePhoto {
            FirebaseStorageHelper.shared.delete(path: .profileImage, id: profileImageId) { error in
                let error2 = FirestorageDownloadUrlCacheModel.remove(id: profileImageId)
                self.error = error ?? error2
                if self.error == nil {
                    needDeletePhoto = false
                    updateProfile()
                }
            }
            return
        }
        
        if let data = photoData {
            FirebaseStorageHelper.shared.uploadData(data: data, contentType: .jpeg, uploadPath: .profileImage, id: profileImageId) { downloadURL, error in            
                self.error = error
                if self.error == nil {
                    photoData = nil
                    updateProfile()
                }
            }
            return
        }    
        profile.updateFirestore(name: name, gender: gender, birthday: birthday) { error in
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            }
            self.error = error
        }
    }
    var deletedView : some View {
        Text("")
            .onAppear {
                presentationMode.wrappedValue.dismiss()
            }
            .navigationTitle("")
    }
    
    var normalView : some View {
        List {
            if isEdited {
                HStack(alignment: .center) {
                    Spacer()
                    VStack {
                        Spacer(minLength: 100)
                        ActivityIndicatorView(isVisible: $isEdited, type: .default(count: 10))
                            .frame(width:50, height:50)
                        Text("update profile...")
                        Spacer(minLength: 100)
                    }
                    Spacer()
                }
            } else {
                Section {
                    PointNeedView(pointCase: .editProfile)
                }
                Section {
                    PhotoPickerView(selectedImageData: $photoData, size: .init(width: 150, height: 150), placeHolder: nil, profileImageView: ProfileImageView(profile: profile, size: .init(width: 150, height: 150), drawRound: false))
                    
                    if profile.profileImageURL != nil  && photoData == nil {
                        Toggle(isOn: $needDeletePhoto) {
                            Text("delete photo")
                        }
                    }
                }
                Section {
                    TitleTextFieldView(
                        id:"name",
                        title: .init("name"),
                        placeHolder: .init("input name"),
                        value: $name)
                    
                    Picker("gender", selection: $gender) {
                        ForEach(ProfileModel.Gender.allCases, id:\.self) {
                            $0.textValue
                        }
                    }
                    
                    DatePicker("birthday", selection: $birthday, displayedComponents: .date)
                }
                
                Section {
                    NavigationLink {
                        DeleteProfileConfirmView(profile:profile)
                    } label: {
                        ImageTextView(image: .init(systemName: "trash.square"), text: .init("delete profile"))
                    }
                    
                }
            }
        }
        .toolbar {
            Button {
                saveWithPointUse()
            } label: {
                Text("save")
            }
        }
        .onAppear {
            if birthday.timeIntervalSince1970 == 0 {
                name = profile.name
                gender = profile.gender ?? .unkonown
                birthday = profile.birthday
            }
        }
        .onDisappear {
            //편집 컨펌 없으면 서버에서 직전 데이터 가져온다.
            if isEdited == false {
                profile.downloadFirestore { error in
                    
                }
            }
        }
        .navigationTitle(Text("edit profile"))
        .alert(isPresented: $isAlert)  {
            if deleteAlert {
                return .init(
                    title: .init("delete profile title"),
                    message: .init("delete profile message"),
                    primaryButton: .cancel(),
                    secondaryButton: .default(.init("confirm"), action: {
                        profile.delete(removeWithLocal: true) { error in
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
        
            switch error as? CustomError {
            case .emptyName:
                return .init(title: .init("alert"),
                             message: .init(error!.localizedDescription),
                             dismissButton: .default(.init("confirm"), action: {
                        NotificationCenter.default.post(name: .textfieldSetFocus, object: "name")
                })
                )
            case .notEnoughPoint:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? ""),
                    primaryButton: .cancel(),
                    secondaryButton: .default(.init("ad watch"), action: {
                        ad.showAd { error in
                            if error == nil {
                                saveWithPointUse()
                            }
                            self.error = error
                        }
                    }))
            default:
                return .init(title: .init("alert"),
                             message: .init(error!.localizedDescription))
            }
            
        }
    }
    var body: some View {
        if profile.id.isEmpty {
            deletedView
        } else {
            normalView
        }
    }
}

#Preview {
    UpdateProfileView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
