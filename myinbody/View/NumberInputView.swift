//
//  NumberInputView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/18/23.
//

import SwiftUI

struct NumberInputView: View {
    let format:String
    let unit:Text?
    @Binding var value:Double {
        willSet {
            loadNumber(value: newValue)
        }
    }
    
    @State private var stringArray:[String] = []
    
    private var count:Int {
        return String(format: format, value).count
    }
    
    private func loadNumber(value:Double) {
        let str = String(format: format, value)
        stringArray = str.arrayValue
    }
        
    private func getValue(idx:Int)->Double {
        var realIdx = idx
        let dotidx = stringArray.firstIndex(of: ".") ?? stringArray.count
        if idx > dotidx {
            realIdx -= 1
        }
        realIdx = stringArray.count - realIdx - (stringArray.count - dotidx) - 1
        print(pow(10,Double(realIdx)))
        return pow(10,Double(realIdx))
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<stringArray.count, id:\.self) {idx in
                    let str = stringArray[idx]
                    VStack {
                        if(str != ".") {
                            LongPressButtonView(image: .init(systemName: "arrow.up.square")) {
                                value += getValue(idx: idx)
                            }
                        }
                        Text("\(str)")
                            .font(.system(size: 50))
                        if(str != ".") {
                            LongPressButtonView(image: .init(systemName: "arrow.down.square")) {
                                let x = getValue(idx: idx)
                                if value - x >= 0 {
                                    value -= getValue(idx: idx)
                                }
                            }
                        }
                    }
                }
                if let u = unit {
                    u
                }
            }
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 2)
        }
        .padding(20)
        .onAppear {
            loadNumber(value: value)
        }
    }
}


#Preview {
    @State var value:Double = 139.12
    return NumberInputView(format: "%.2f", unit: .init("kg"), value: $value)
}
