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
            isAlert = error != nil
        }
    }
    @State var isAlert:Bool = false
    @ObservedRealmObject var inbodyModel:InbodyModel

    let ad = GoogleAd()
    @State var data:[InbodyModel.InbodyInputDataType:String] = [:]
    @State var isUpdateSucess:Bool = false 
    var body: some View {
        List {
            ForEach(InbodyModel.InbodyInputDataType.allCasesForEditInbody, id:\.self) { type in
                NavigationLink {
                    switch type {
                    case .height:
                        InbodyDataEditView(type: type, value: $inbodyModel.height )
                    case .weight:
                        InbodyDataEditView(type: type, value: $inbodyModel.weight )
                    case .skeletal_muscle_mass:
                        InbodyDataEditView(type: type, value: $inbodyModel.skeletal_muscle_mass )
                    case .body_fat_mass:
                        InbodyDataEditView(type: type, value: $inbodyModel.body_fat_mass )
                    case .total_body_water:
                        InbodyDataEditView(type: type, value: $inbodyModel.total_body_water )
                    case .protein:
                        InbodyDataEditView(type: type, value: $inbodyModel.protein )
                    case .mineral:
                        InbodyDataEditView(type: type, value: $inbodyModel.mineral )
                    case .percent_body_fat:
                        InbodyDataEditView(type: type, value: $inbodyModel.percent_body_fat )
                    case .waist_hip_ratio:
                        InbodyDataEditView(type: type, value: $inbodyModel.waist_hip_ratio )
                    case .basal_metabolic_ratio:
                        InbodyDataEditView(type: type, value: $inbodyModel.basal_metabolic_ratio )
                    case .visceral_fat:
                        InbodyDataEditView(type: type, value: $inbodyModel.visceral_fat )
                    default:
                        InbodyDataEditView(type: type, value: $inbodyModel.height )
                    }
                    
                } label: {
                    HStack {
                        type.textValue
                        let value = inbodyModel.getValueByType(type: type)
                        Text(String(format:type.formatString,value))
                            .bold()
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
            
        }
        .toolbar {
            Button {
                saveData()
            } label : {
                Text("save")
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
        .navigationTitle(inbodyModel.measurementDateTime.formatting(format: "yyyy.MM.dd hh:mm:ss"))
        
        .onDisappear {
            if isUpdateSucess == false {
                inbodyModel.download { error in
                    
                }
            }
        }
    }
    
    func saveData() {
        PointModel.use(useCase: .inbodyDataEdit) { error in
            self.error = error
            if error == nil {
                inbodyModel.update { error in
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
