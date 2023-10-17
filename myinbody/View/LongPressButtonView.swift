//
//  LongPressButtonView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/17/23.
//

import SwiftUI

struct LongPressButtonView: View {
    let image: Image
    let action: ()->Void
    
    @State var isLoop = false
    @State var actionInterval:TimeInterval = 0
    var body: some View {
        Button {
            actionInterval = Date().timeIntervalSince1970
            action()
        } label: {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 50,height: 50)
                .foregroundStyle(.primary,.orange,.secondary)
        }
        .onLongPressGesture(minimumDuration:50, maximumDistance: 100,perform: {
            print("long")
        }) { changed in
            print("long : \(changed)")
            isLoop = changed
            if changed {
                loopCall()
            }
        }
                    
    }
    func loopCall() {
        let interval = Date().timeIntervalSince1970 - actionInterval
        if interval < 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                loopCall()
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if isLoop {
                action()
                loopCall()
            }
        }
    }
}

#Preview {
    LongPressButtonView(image: Image(systemName:"minus.square")) {
        print("action!!")
    }
}
