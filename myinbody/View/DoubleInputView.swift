//
//  DoubleInputView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/17/23.
//

import SwiftUI

struct DoubleInputView: View {
    let title:Text
    let unit:Text
    let range:ClosedRange<Double>
    let min:Double
    let format:String 
    @Binding var value:Double

    var body: some View {
        VStack {
            title
                .font(.system(size: 25))
                .foregroundStyle(.primary)
                .padding(.bottom, 20)
         
            
            HStack {
                Text(String(format:format, value))
                    .font(.system(size: 50,weight: .heavy))
                    .foregroundStyle(.primary)
                unit
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                VStack {
                    LongPressButtonView(image: .init(systemName: "plus.app")) {
                        value += min
                    }
                    LongPressButtonView(image: .init(systemName: "minus.square")) {
                        value -= min
                    }
                }
            }

            HStack {
                Text(String(format:format,range.lowerBound))
                Slider(value: $value, in: range) { changed in
                }
                Text(String(format:format,range.upperBound))
            }
        }
        .padding(30)
        .overlay{
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 2.0)
        }
        .padding(20)
    }
}

#Preview {
    DoubleInputView(
        title: .init("test"),
        unit: .init("cm"),
        range: 0...10,
        min:0.1,
        format:"%0.2f",
        value: .constant(7.4123))
}
