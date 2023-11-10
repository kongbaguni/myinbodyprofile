//
//  PointNeedView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/10/23.
//

import SwiftUI

struct PointNeedView: View {
    let pointCase: PointModel.PointUseCase
    @State var currentPoint:Int = PointModel.sum
    
    var body: some View {
        Group {
            HStack {
                Text("points needed :").foregroundStyle(.secondary)
                Text("\(pointCase.rawValue)").bold()
            }
            HStack {
                Text("Current Point :").foregroundStyle(.secondary)
                Text("\(PointModel.sum)").bold()
            }
        }.onReceive(NotificationCenter.default.publisher(for: .pointDidChanged), perform: { noti in
            currentPoint = noti.object as? Int ?? PointModel.sum
        })
    }
}

#Preview {
    PointNeedView(pointCase: .createProfile)
}
