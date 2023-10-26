//
//  PhotoPickerView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import PhotosUI
import AlamofireImage

struct PhotoPickerView: View {
    @State var selectedItem:PhotosPickerItem? = nil
    
    @Binding var selectedImageData:Data?
    let size:CGSize
    var selectedImage:SwiftUI.Image? {
        if let data = selectedImageData {
            return .init(uiImage: .init(data: data)!)
        }
        return nil
    }
    
    var body: some View {
        PhotosPicker(selection: $selectedItem) {
            Group {
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width:size.width,height:size.height)
                        .cornerRadius(10)
                        .clipped()
                } else {
                    Text("select photo")
                        .padding(10)
                }
            }
            .foregroundColor(.primary)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 2)
                    .shadow(radius: 20)
            }

        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image:UIImage = .init(data: data) {
                    let newImage = image.af.imageAspectScaled(toFill: .init(width: 150, height: 150))
                    selectedImageData = newImage.jpegData(compressionQuality: 5)
                }
            }
        }
    }
}

#Preview {
    PhotoPickerView(selectedImageData: .constant(nil), size:.init(width: 150, height: 150))
}
