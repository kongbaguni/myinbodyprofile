//
//  AnimatedImageView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/25/23.
//

import SwiftUI

struct AnimatedImageView: View {
    let images:[Image]
    let interval:TimeInterval
    let forgroundStyle:(Color,Color,Color)
    let size:CGSize
    
    @State private var index:Int = 0
    @State private var timers:[Timer] = []
    @State private var shadowCount:CGFloat = 0
    @State private var shadowVector:CGFloat = 0.1
    @State private var shadowMaxLimit:CGFloat = 100
    var body: some View {
        images[index]
            .resizable()
            .scaledToFit()
            .frame(width:size.width,height: size.height)
            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
            .foregroundStyle(forgroundStyle.0,
                             forgroundStyle.1,
                             forgroundStyle.2)
            .shadow(color:.secondary,
                    radius: 10 + shadowCount / 5,
                    x: shadowCount * cos(shadowCount),
                    y: shadowCount * sin(shadowCount)
            )
            .onAppear {
                timers.append( Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { timer in
                    loop()
                }))
                timers.append(.scheduledTimer(withTimeInterval: 1/60, repeats: true, block: { timer in
                    shadowCount += shadowVector
                    if shadowCount > shadowMaxLimit || shadowCount < 0 {
                        shadowMaxLimit = .random(in: 100...200)
                        shadowVector *= -CGFloat.random(in: 0.1...2)
                        while abs(shadowVector) < 0.1 {
                            shadowVector *= 2
                        }
                        while abs(shadowVector) > 3{
                            shadowVector *= 0.5
                        }
                    }
                }))
                
            }
            .onDisappear {
                for timer in timers {
                    timer.invalidate()
                }
                timers.removeAll()
            }
    }
    
    private func loop() {
        if index + 1 >= images.count {
            index = 0
        } else {
            index += 1
        }
    }
}

#Preview {
    AnimatedImageView(images: [
        .init(systemName: "figure.stand"),
        .init(systemName: "figure.walk"),
        .init(systemName: "figure.wave"),
        .init(systemName: "figure.walk.circle")
    ], 
                      interval: 2,
                      forgroundStyle: (.blue,.orange, .red),
                      size:.init(width: 150, height: 150)
    )
}
