//
//  FirebaseStorageHelper.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore

extension Notification.Name {
    /** 프로필 이미지 갱신됨 */
    static let profileImageUpdated = Notification.Name("ProfileImageUpdated_observer")
}

class FirebaseStorageHelper {
    enum DataPath : String {
        case profileImage = "profileimages"
    }
    
    static let shared = FirebaseStorageHelper()
    
    let storageRef = Storage.storage().reference()
    
    var documentReferance:DocumentReference? = nil
    
    enum ContentType:String {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }
    
    func uploadImage(url:URL, contentType:ContentType, uploadPath:DataPath, id:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
        guard var data = try? Data(contentsOf: url) else {
            complete(nil, nil)
            return
        }
        switch contentType {
        case .png:
            if let pngData = UIImage(data: data)?.pngData() {
                data = pngData
            }

        case .jpeg:
            if let jpgData = UIImage(data: data)?.jpegData(compressionQuality: 0.7) {
                data = jpgData
            }
        }

        uploadData(data: data, contentType: contentType, uploadPath: uploadPath, id: id, complete: complete)
    }

    
    func uploadData(data:Data, contentType:ContentType, uploadPath:DataPath, id:String, complete:@escaping(_ downloadURL:URL?, _ error:Error?)->Void) {
        let ref:StorageReference = storageRef.child("\(uploadPath.rawValue)/\(id)")
        let metadata = StorageMetadata()
        metadata.contentType = contentType.rawValue
        let task = ref.putData(data, metadata: metadata)
        task.observe(.success) { (snapshot) in
            let path = snapshot.reference.fullPath
            print(snapshot.reference.name)
            print(path)
            
            ref.downloadURL { (downloadUrl, err) in
                var err:Error? = nil
                if let url = downloadUrl {
                    err = FirestorageDownloadUrlCacheModel.reg(id: id, url: url.absoluteString)
                }
                NotificationCenter.default.post(name: .profileImageUpdated, object: downloadUrl)
                complete(downloadUrl, err)
            }
        }
        task.observe(.failure) { snapshot in
            complete(nil, snapshot.error)
        }
    }
        
    func getDownloadURL(uploadPath:DataPath, id:String, complete:@escaping(_ url:URL?, _ error:Error?)->Void) {
        let ref:StorageReference = storageRef.child("\(uploadPath.rawValue)/\(id)")
        ref.downloadURL {  downloadURL, err in
            if let url = downloadURL {
                _ = FirestorageDownloadUrlCacheModel.reg(id: id, url: url.absoluteString)
            }
            complete(downloadURL,err)
        }
    }
    
    func delete(path:DataPath, id:String,complete:@escaping(_ error:Error?)->Void) {
        let ref = storageRef.child("\(path.rawValue)/\(id)")
        ref.delete { error in
            complete(error)
        }
    }
        
}


