//
//  CornerButton.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CornerButton: View {
    var title: String
    var fontSize: Double
    var fontWeight: Font.Weight
    var buttonAction: (() -> Void)?
    var cornerRadius: Double
    var verticalPadding: Double

    init(
        title: String,
        fontSize: Double = 16,
        fontWeight: Font.Weight = .regular,
        buttonAction: (() -> Void)? = nil,
        cornerRadius: Double = 0.0,
        verticalPadding: Double
    ) {
        self.title = title
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.buttonAction = buttonAction
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
    }
    
    var body: some View {
        Button {
            if let buttonAction = buttonAction {
                buttonAction()
            }
        } label: {
            Text(title)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(.customWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, verticalPadding)
        }
        .background(.customBlack)
        .cornerRadius(cornerRadius)
    }
}

#Preview {
    CornerButton(
        title: "방만들기",
        buttonAction: {},
        verticalPadding: 4.0
    )
}
