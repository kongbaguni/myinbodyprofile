//
//  InbodyDataInputView.swift
//  myinbody
//
//  Created by Changyeol Seo on 10/17/23.
//

import SwiftUI
import RealmSwift

struct InbodyDataInputView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedRealmObject var profile:ProfileModel

    @State var height:Double = 170.0
    @State var weight:Double = 70.0
    @State var skeletal_muscle_mass:Double = 30.0
    @State var measurementDate:Date = Date()
    @State var body_fat_mass:Double = 30.0
    @State var total_body_water:Double = 40.0
    @State var protein:Double = 10.0
    @State var mineral:Double = 10.0
    @State var step:InbodyModel.InbodyInputDataType = InbodyModel.InbodyInputDataType.allCases.first!
    @State var bmi:Double = 20.0
    @State var percent_body_fat:Double = 30.0
    @State var waist_hip_ratio:Double = 0.92
    @State var basal_metabolic_ratio:Double = 1800
    @State var visceral_fat:Double = 5.0
    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true 
            }
        }
    }
    @State var isAlert:Bool = false
    var stepCount:Int {
        InbodyModel.InbodyInputDataType.allCases.firstIndex(of: step) ?? 0
    }
    
    func getRange(step:InbodyModel.InbodyInputDataType,defaultRange:ClosedRange<Double>)->ClosedRange<Double> {
        let r:Double = 10
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
            case .bmi:
                return last.bmi-r...last.bmi+r
            case .percent_body_fat:
                return last.percent_body_fat-r...last.percent_body_fat+r
            case .waist_hip_ratio:
                return last.waist_hip_ratio-r...last.waist_hip_ratio+r
            case .basal_metabolic_ratio:
                return last.basal_metabolic_ratio-r...last.basal_metabolic_ratio+r
            case .visceral_fat:
                return last.visceral_fat-r...last.visceral_fat+r
            default:
                return 0...0
            }
        }
        return defaultRange
    }
    var title : some View {
        return HStack {
            step.textValue.font(.title)
                .foregroundStyle(.primary)
            Spacer()
        }.padding(20)

    }
    
    var body: some View {
        VStack(alignment:.center) {
            title
            switch step {
            case .height:
                InbodyChartView(profile: profile, dataType: step, last:height)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $height)
                
            case .weight:
                InbodyChartView(profile: profile, dataType: step, last:weight)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $weight)
                
            case .skeletal_muscle_mass:
                InbodyChartView(profile: profile, dataType: step, last:skeletal_muscle_mass)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $skeletal_muscle_mass)
                
            case .body_fat_mass:
                InbodyChartView(profile: profile, dataType: step, last:body_fat_mass)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $body_fat_mass)
                
            case .total_body_water:
                InbodyChartView(profile: profile, dataType: step, last:total_body_water)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $total_body_water)

            case .protein:
                InbodyChartView(profile: profile, dataType: step, last:protein)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $protein)

            case .mineral:
                InbodyChartView(profile: profile, dataType: step, last:mineral)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $mineral)
                
            case .bmi:
                InbodyChartView(profile: profile, dataType: step, last:bmi)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $bmi)
            case .percent_body_fat:
                InbodyChartView(profile: profile, dataType: step, last:percent_body_fat)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $percent_body_fat)

            case .waist_hip_ratio:
                InbodyChartView(profile: profile, dataType: step, last:waist_hip_ratio)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $waist_hip_ratio)

            case .basal_metabolic_ratio:
                InbodyChartView(profile: profile, dataType: step, last:basal_metabolic_ratio)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $basal_metabolic_ratio)
                
            case .visceral_fat:
                InbodyChartView(profile: profile, dataType: step, last:visceral_fat)
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $visceral_fat
                )
                
            case .measurementDate:
                DatePicker(selection: $measurementDate) {
                    Text("inbody input title measurementDate")
                }
                .padding(20)
                .frame(height: 300)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2.0)
                }
                .padding(20)
                
            }
            Spacer()
            HStack {
                if stepCount > 0 {
                    Button {
                        let prev = stepCount - 1
                        if prev >= 0 {
                            step = InbodyModel.InbodyInputDataType.allCases[prev]
                        }
                    } label: {
                        Text("previous")
                    }
                }
                switch step {
                case InbodyModel.InbodyInputDataType.allCases.last:
                    Button {
                        save()
                    } label: {
                        Text("confirm")
                    }
                default:
                    Button {
                        let next = stepCount + 1
                        if InbodyModel.InbodyInputDataType.allCases.count > next {
                            step = InbodyModel.InbodyInputDataType.allCases[next]
                        }
                    } label: {
                        Text("next")
                    }
                }
            }
        }
        .navigationTitle(.init("input inbody data"))
        .onAppear {
            #if targetEnvironment(simulator)
            return 
            #endif
        
            guard let last = profile.inbodys.sorted(byKeyPath: "measurementDateTimeIntervalSince1970").last else {
                return
            }
            height = last.height
            weight = last.weight
            skeletal_muscle_mass = last.skeletal_muscle_mass
            body_fat_mass = last.body_fat_mass
            total_body_water = last.total_body_water
            protein = last.protein
            mineral = last.mineral
            bmi = last.bmi
            percent_body_fat = last.percent_body_fat
            waist_hip_ratio = last.waist_hip_ratio
            basal_metabolic_ratio = last.basal_metabolic_ratio
            visceral_fat = last.visceral_fat

        }
    }
    
    func save() {
        InbodyModel.append(data: [
            "height":height,
            "weight":weight,
            "skeletal_muscle_mass":skeletal_muscle_mass,
            "measurementDateTimeIntervalSince1970":measurementDate.timeIntervalSince1970,
            "body_fat_mass":body_fat_mass,
            "total_body_water":total_body_water,
            "protein":protein,
            "mineral":mineral,
            "bmi":bmi,
            "percent_body_fat":percent_body_fat,
            "waist_hip_ratio":waist_hip_ratio,
            "basal_metabolic_ratio":basal_metabolic_ratio,
            "visceral_fat":visceral_fat,
            "regDt":Date().timeIntervalSince1970
        ], profile: profile) { error in
            self.error = error
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    InbodyDataInputView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
