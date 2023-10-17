//
//  InbodyDataInputView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/17/23.
//

import SwiftUI
import RealmSwift

struct InbodyDataInputView: View {
    enum InputStep : CaseIterable {
        case measurementDate
        case height
        case weight
        case skeletal_muscle_mass
        case body_fat_mass
        case total_body_water
        case protein
        case mineral
    }
    
    @ObservedRealmObject var profile:ProfileModel

    @State var height:Double = 170.0
    @State var weight:Double = 70.0
    @State var skeletal_muscle_mass:Double = 30.0
    @State var measurementDate:Date = Date()
    @State var body_fat_mass:Double = 30.0
    @State var total_body_water:Double = 40.0
    @State var protein:Double = 10.0
    @State var mineral:Double = 10.0
    @State var step:InputStep = InputStep.allCases.first!
    
    var stepCount:Int {
        InputStep.allCases.firstIndex(of: step) ?? 0
    }
    
    func getRange(step:InputStep,defaultRange:ClosedRange<Double>)->ClosedRange<Double> {
        let r:Double = 50
        if let last = profile.inbodys.last {
            switch step {
            case .weight:
                return last.weight-r...last.weight+r
            case .height:
                return last.height-r...last.height+r
            case .skeletal_muscle_mass:
                return last.skeletal_muscle_mass-r...last.skeletal_muscle_mass+r
            case .body_fat_mass:
                return last.body_fat_mass-r...last.body_fat_mass+r
            case .total_body_water:
                return last.total_body_water-r...last.total_body_water+r
            case .protein:
                return last.protein-r...last.protein+r
            case .mineral:
                return last.mineral-r...last.mineral+r
            default:
                return 0...0
            }
        }
        return defaultRange
    }
    
    var body: some View {
        VStack {
            switch step {
            case .height:
                DoubleInputView(
                    title: .init("inbody input title height"),
                    unit: .init("cm"),
                    range: getRange(step: step, defaultRange: 40...400),
                    min:1,
                    format:"%0.0f",
                    value: $height
                )
            case .weight:
                DoubleInputView(
                    title: .init("inbody input title weight"),
                    unit: .init("kg"),
                    range: getRange(step: step, defaultRange: 20...300),
                    min:0.1,
                    format: "%0.1f",
                    value: $weight
                )
            case .skeletal_muscle_mass:
                DoubleInputView(
                    title: .init("inbody input title skeletal muscle mass"),
                    unit: .init("kg"),
                    range: getRange(step: step, defaultRange: 0...200),
                    min:0.1,
                    format: "%.1f",
                    value: $skeletal_muscle_mass
                )
            case .body_fat_mass:
                DoubleInputView(
                    title: .init("inbody input title body fat mass"),
                    unit: .init("kg"),
                    range: getRange(step: step, defaultRange: 0...200),
                    min: 0.1,
                    format: "%.1f",
                    value: $body_fat_mass
                )
            case .total_body_water:
                DoubleInputView(
                    title: .init("inbody input title total body water"),
                    unit: .init("ℓ"),
                    range: getRange(step: step, defaultRange: 0...100),
                    min: 0.1,
                    format: "%.1f",
                    value: $total_body_water
                )
            case .protein:
                DoubleInputView(
                    title: .init("inbody input title protein"),
                    unit: .init("kg"),
                    range: getRange(step: step, defaultRange: 0...100),
                    min: 0.1,
                    format: "%.1f",
                    value: $protein
                )
            case .mineral:
                DoubleInputView(
                    title: .init("inbody input title mineral"),
                    unit: .init("kg"),
                    range: getRange(step: step, defaultRange: 0...100),
                    min: 0.1,
                    format: "%.1f",
                    value: $mineral)
                
            case .measurementDate:
                DatePicker(selection: $measurementDate) {
                    Text("inbody input title measurementDate")
                }
                .padding(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2.0)
                }
                .padding(20)
            }
            HStack {
                if stepCount > 0 {
                    Button {
                        let prev = stepCount - 1
                        if prev >= 0 {
                            step = InputStep.allCases[prev]
                        }
                    } label: {
                        Text("previous")
                    }
                }
                switch step {
                case InputStep.allCases.last:
                    Button {
                        
                    } label: {
                        Text("confirm")
                    }
                default:
                    Button {
                        let next = stepCount + 1
                        if InputStep.allCases.count > next {
                            step = InputStep.allCases[next]
                        }
                    } label: {
                        Text("next")
                    }
                }
            }
        }
        .navigationTitle(.init("input inbody data"))
        .onAppear {
            guard let last = profile.inbodys.last else {
                return
            }
            height = last.height
            weight = last.weight
            
        }
    }
}

#Preview {
    InbodyDataInputView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
