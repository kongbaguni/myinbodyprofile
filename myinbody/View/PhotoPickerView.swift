//
//  PhotoPickerView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/13/23.
//

import SwiftUI
import PhotosUI
struct PhotoPickerView: View {
    @State var selectedItem:PhotosPickerItem? = nil
    @Binding var selectedImageData:Data?
    var selectedImage:Image? {
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
                        .scaledToFit()
                        .frame(width:100)
                        .cornerRadius(10)
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
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}

#Preview {
    PhotoPickerView(selectedImageData: .constant(nil))
//    PhotoPickerView()
}
