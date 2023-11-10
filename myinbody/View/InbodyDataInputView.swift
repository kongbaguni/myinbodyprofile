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
    
    let ad = GoogleAd()
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
    @State var saveConfirm:Bool = false
    @State var isFirstLoaded:Bool = false
    var stepCount:Int {
        InbodyModel.InbodyInputDataType.allCases.firstIndex(of: step) ?? 0
    }
    
    var title : some View {
        return HStack {
            step.textValue.font(.title)
                .foregroundStyle(.primary)
            Spacer()
        }.padding(20)

    }
    
    var inputView : some View {
        VStack(alignment:.center) {
            title
            switch step {
            case .height:
                InbodyChartView(profile: profile, dataType: step ,last:(date:measurementDate,value:height))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $height)
                
            case .weight:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate,value:weight))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $weight)
                
            case .skeletal_muscle_mass:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:skeletal_muscle_mass))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $skeletal_muscle_mass)
                
            case .body_fat_mass:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:body_fat_mass))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $body_fat_mass)
                
            case .total_body_water:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:total_body_water))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $total_body_water)

            case .protein:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:protein))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $protein)

            case .mineral:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:mineral))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $mineral)
                
            case .bmi, .inbodyPoint:
                EmptyView()
                
            case .percent_body_fat:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:percent_body_fat))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $percent_body_fat)

            case .waist_hip_ratio:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:waist_hip_ratio))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $waist_hip_ratio)

            case .basal_metabolic_ratio:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:basal_metabolic_ratio))
                NumberInputView(
                    format: step.formatString,
                    unit: step.unit,
                    value: $basal_metabolic_ratio)
                
            case .visceral_fat:
                InbodyChartView(profile: profile, dataType: step, last:(date:measurementDate, value:visceral_fat))
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
                        ImageTextView(image: .init(systemName: "arrowshape.backward"),
                                      text: .init("previous"))
                    }
                }
                switch step {
                case InbodyModel.InbodyInputDataType.allCases.last:
                    Button {
                        saveConfirm = true
                    } label: {
                        ImageTextView(image: .init(systemName: "return"),
                                      text: .init("confirm"))
                    }
                default:
                    Button {
                        let next = stepCount + 1
                        if InbodyModel.InbodyInputDataType.allCases.count > next {
                            step = InbodyModel.InbodyInputDataType.allCases[next]
                        }
                    } label: {
                        ImageTextView(image: .init(systemName: "arrowshape.forward"),
                                      text: .init("next"))
                    }
                }
            }
        }
    }
    
    func getValue(type:InbodyModel.InbodyInputDataType)->Double {
        switch type {
        case .height:
            return height
        case .weight:
            return weight
        case .skeletal_muscle_mass:
            return skeletal_muscle_mass
        case .body_fat_mass:
            return body_fat_mass
        case .total_body_water:
            return total_body_water
        case .protein:
            return protein
        case .mineral:
            return mineral
        case .percent_body_fat:
            return percent_body_fat
        case .waist_hip_ratio:
            return waist_hip_ratio
        case .basal_metabolic_ratio:
            return basal_metabolic_ratio
        case .visceral_fat:
            return visceral_fat
        default:
            return 0
        }
    }
    
    func makeDataView(type:InbodyModel.InbodyInputDataType)-> some View {
        HStack {
            type.textValue
            Text(String(format:type.formatString, getValue(type: type)))
                .bold()
                .foregroundStyle(.primary)
            if let unit = type.unit {
                unit
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    func makeEditLinkView(type:InbodyModel.InbodyInputDataType)-> some View {
        Group {
            switch type {
            case .measurementDate:
                DatePicker(selection: $measurementDate) {
                    Text("inbody input title measurementDate")
                }
            default:
                NavigationLink {
                    switch type {
                    case .height:
                        InbodyDataEditView(type: type, value: $height)
                    case .weight:
                        InbodyDataEditView(type: type, value: $weight)
                    case .skeletal_muscle_mass:
                        InbodyDataEditView(type: type, value: $skeletal_muscle_mass)
                    case .body_fat_mass:
                        InbodyDataEditView(type: type, value: $body_fat_mass)
                    case .total_body_water:
                        InbodyDataEditView(type: type, value: $total_body_water)
                    case .protein:
                        InbodyDataEditView(type: type, value: $protein)
                    case .mineral:
                        InbodyDataEditView(type: type, value: $mineral)
                    case .percent_body_fat:
                        InbodyDataEditView(type: type, value: $percent_body_fat)
                    case .waist_hip_ratio:
                        InbodyDataEditView(type: type, value: $waist_hip_ratio)
                    case .basal_metabolic_ratio:
                        InbodyDataEditView(type: type, value: $basal_metabolic_ratio)
                    case .visceral_fat:
                        InbodyDataEditView(type: type, value: $visceral_fat)
                    default:
                        EmptyView()
                    }
                } label: {
                    makeDataView(type: type)
                }
            }
        }
    }
    
    var saveConfirmView : some View {
        List {
            ForEach(InbodyModel.InbodyInputDataType.allCases, id:\.self) { type in
                makeEditLinkView(type: type)
            }

            Section {
                PointNeedView(pointCase: .inbodyDataInput)
            }
            
            Section {
                Button {
                    saveConfirm = false
                } label: {
                    ImageTextView(image: .init(systemName: "arrowshape.backward"),
                                  text: .init("previous"))
                }
                Button {
                    save()
                } label : {
                    ImageTextView(image: .init(systemName:"opticaldiscdrive"), text: .init("save"))
                }
            }
        }
    }
    var body: some View {
        GeometryReader { proxy in
            if saveConfirm {
                saveConfirmView
            } else {
                inputView
            }
            
        }
        .navigationTitle(.init("input inbody data"))
        .onAppear {
            #if targetEnvironment(simulator)
            return 
            #endif
                                
            guard let last = profile.inbodys.filter("deleted = %@",false).sorted(byKeyPath: "measurementDateTimeIntervalSince1970").last else {
                return
            }
            if isFirstLoaded {
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
            isFirstLoaded = true
        }
        .alert(isPresented: $isAlert) {
            switch error as? CustomError {
            case .notEnoughPoint:
                return .init(title: .init("alert"),
                             message: .init(error?.localizedDescription ?? ""),
                             primaryButton: .cancel(),
                             secondaryButton: .default(.init("ad watch"), action: {
                    ad.showAd { error in
                        if error == nil {
                            save()
                        }
                        self.error = error
                    }
                }))
                                            
            default:
                return .init(title: .init("alert"),
                             message: .init(error?.localizedDescription ?? "")
                )
            }
        }
    }
    
    func save() {
        PointModel.use(useCase: .inbodyDataInput) { error in
            if error == nil {
                let now = Date().timeIntervalSince1970
                InbodyModel.append(data: [
                    "height":height,
                    "weight":weight,
                    "skeletal_muscle_mass":skeletal_muscle_mass,
                    "measurementDateTimeIntervalSince1970":measurementDate.timeIntervalSince1970,
                    "body_fat_mass":body_fat_mass,
                    "total_body_water":total_body_water,
                    "protein":protein,
                    "mineral":mineral,
                    "percent_body_fat":percent_body_fat,
                    "waist_hip_ratio":waist_hip_ratio,
                    "basal_metabolic_ratio":basal_metabolic_ratio,
                    "visceral_fat":visceral_fat,
                    "regDtTimeIntervalSince1970":now,
                    "updateDtTimeIntervalSince1970":now
                    
                ], profile: profile) { error in
                    self.error = error
                    if error == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            self.error = error
        }
    }
}

#Preview {
    InbodyDataInputView(profile: .init(value: ["id":"test","name":"홍길동"]))
}
