//
//  InbodyDataEditView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/9/23.
//

import SwiftUI
import RealmSwift

struct InbodyDataDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var error:Error? = nil {
        didSet {
            if error != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    @ObservedRealmObject var inbodyModel:InbodyModel

    @State var tempData:InbodyModel = .init()
    
    let ad = GoogleAd()
    @State var data:[InbodyModel.InbodyInputDataType:String] = [:]
    @State var isUpdateSucess:Bool = false 
    var list: some View {
        List {
            Section {
                PointNeedView(pointCase: .inbodyDataEdit)
            }
            HStack {
                Text("inbody input title measurementDate")
                Text(inbodyModel.measurementDateTime.formatting(format: "yyyy.MM.dd hh:mm:ss"))
                    .bold()
            }
            ForEach(InbodyModel.InbodyInputDataType.allCasesForEditInbody, id:\.self) { type in
                NavigationLink {
                    switch type {
                    case .height:
                        InbodyDataEditView(type: type, value: $tempData.height )
                    case .weight:
                        InbodyDataEditView(type: type, value: $tempData.weight )
                    case .skeletal_muscle_mass:
                        InbodyDataEditView(type: type, value: $tempData.skeletal_muscle_mass )
                    case .body_fat_mass:
                        InbodyDataEditView(type: type, value: $tempData.body_fat_mass )
                    case .total_body_water:
                        InbodyDataEditView(type: type, value: $tempData.total_body_water )
                    case .protein:
                        InbodyDataEditView(type: type, value: $tempData.protein )
                    case .mineral:
                        InbodyDataEditView(type: type, value: $tempData.mineral )
                    case .percent_body_fat:
                        InbodyDataEditView(type: type, value: $tempData.percent_body_fat )
                    case .waist_hip_ratio:
                        InbodyDataEditView(type: type, value: $tempData.waist_hip_ratio )
                    case .basal_metabolic_ratio:
                        InbodyDataEditView(type: type, value: $tempData.basal_metabolic_ratio )
                    case .visceral_fat:
                        InbodyDataEditView(type: type, value: $tempData.visceral_fat )
                    default:
                        InbodyDataEditView(type: type, value: $tempData.height )
                    }
                    
                } label: {
                    HStack {
                        type.textValue
                        let oldValue = inbodyModel.getValueByType(type: type)
                        let value = tempData.getValueByType(type: type)
                        if oldValue == value {
                            Text(String(format:type.formatString,oldValue))
                                .bold()
                            
                        } else {
                            Text(String(format:type.formatString,oldValue))
                                .foregroundStyle(.secondary)
                                .strikethrough()
                            if let unit = type.unit {
                                unit.font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("->")
                                .foregroundStyle(.yellow)
                                .bold()
                            Text(String(format:type.formatString,value))
                                .foregroundStyle(.primary)
                                .bold()
                        }
                        
                        if let unit = type.unit {
                            unit.font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                }
            }
            HStack {
                Text("reg dt :").foregroundStyle(.secondary)
                Text(inbodyModel.regDateTime.formatting(format: "yyyy.MM.dd hh:mm:ss")).foregroundStyle(.primary)
            }
            if inbodyModel.regDtTimeIntervalSince1970 != inbodyModel.updateDtTimeIntervalSince1970 {
                HStack {
                    Text("update dt :").foregroundStyle(.secondary)
                    Text(inbodyModel.updateDateTime.formatting(format: "yyyy.MM.dd hh:mm:ss")).foregroundStyle(.primary)
                }
            }
            
            Section("ad"){
                NativeAdView()
            }
            
            Section {
                NavigationLink {
                    InbodyDataDeleteConfirmView(inbodyModel: inbodyModel)
                    
                } label: {
                    ImageTextView(image: .init(systemName: "trash.circle"), text: .init("delete"))
                }

            }
        }
        .toolbar {
            Button {
                saveData()
            } label : {
                Text("save")
            }
        }
        .onAppear {
            if tempData.id.isEmpty {
                tempData = .init(value:inbodyModel.dictionmaryValue)
                tempData.owner = inbodyModel.owner
            }
        }
        .alert(isPresented: $isAlert, content: {
            switch error as? CustomError {
            case .notEnoughPoint:
                return .init(
                    title: .init("alert"),
                    message: .init(error?.localizedDescription ?? ""),
                    primaryButton: .cancel({
                       
                    }),
                    secondaryButton: .default(.init("ad watch"), action: {
                        ad.showAd { error in
                            if error == nil {
                                saveData()
                            }
                            else {
                                self.error = error
                            }
                        }
                    }))
            default:
                return .init(title: .init("alert"), message:.init(error?.localizedDescription ?? ""))

                
            }
        })
        .navigationTitle(.init("inbody data edit"))
        
        .onDisappear {
            if isUpdateSucess == false {
                inbodyModel.download { error in
                    
                }
            }
        }
    }
    
    var body: some View {
        if inbodyModel.deleted {
            Text("deleted")
        } else {
            list
        }
    }
    
    func saveData() {
        if tempData.id.isEmpty {
            return
        }
        PointModel.use(useCase: .inbodyDataEdit) { error in
            self.error = error
            if error == nil {
                tempData.save { error in
                    self.error = error
                    if error == nil {
                        isUpdateSucess = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        NavigationStack {
            InbodyDataDetailView(inbodyModel: .init(value:[
                "id":"test",
                "weight":80,
                "height":168,
                "skeletal_muscle_mass":100,
                "measurementDateTimeIntervalSince1970":123123123
            ]))
        }
    }
}
