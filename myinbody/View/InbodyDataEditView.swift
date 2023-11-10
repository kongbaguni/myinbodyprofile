//
//  InbodyDataEditView.swift
//  myinbody
//
//  Created by Changyeol Seo on 11/10/23.
//

import SwiftUI

struct InbodyDataEditView: View {
    let type:InbodyModel.InbodyInputDataType
    @Binding var value:Double
    var body: some View {
        ScrollView {
            NumberInputView(format: type.formatString, unit: type.unit, value: $value)
                .navigationTitle(type.textValue)
        }        
    }
}

#Preview {
    NavigationView {
        NavigationStack {
            InbodyDataEditView(type: .bmi, value: .constant(100))
        }
    }
}
