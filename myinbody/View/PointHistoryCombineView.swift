//
//  PointHistoryCombineView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/14/23.
//

import SwiftUI

struct PointHistoryCombineView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var progress:Progress? = nil
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    
    @State var isAlert:Bool = false
    var body: some View {
        List {
            Text("combine point history alert")
            if let p = progress {
                ProgressView("combine point", value: .init(Float(p.completedUnitCount) / Float(p.totalUnitCount)))
            } else {
                Button {
                    PointModel.pointLogCombine { progress in
                        self.progress = progress
                    } complete: { error in
                        if error == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                        self.error = error
                    }
                    
                } label: {
                    ImageTextView(image: .init(systemName: "return"),
                                  text: .init("confirm"))
                }
            }

        }
        .navigationSplitViewStyle(.prominentDetail)
        .navigationTitle("combin point history")
    }
}

#Preview {
    NavigationView {
        NavigationStack {
            PointHistoryCombineView()
        }
    }
}
