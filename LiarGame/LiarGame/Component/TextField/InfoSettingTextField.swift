//
//  InfoSettingTextField.swift
//  LiarGame
//
//  Created by 김동준 on 1/5/24
//

import Foundation
import SwiftUI

struct InfoSettingTextField: View {
    let placeHolder: String
    let text: Binding<String>
    
    var body: some View {
        TextField(
            placeHolder,
            text: text
        )
        .padding(.horizontal, 24)
        .textFieldStyle(.roundedBorder)
    }
}

#Preview {
    InfoSettingTextField(
        placeHolder: "placeHolder",
        text: Binding<String>.constant("")
    )
}
