//
//  CornerButton.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CornerButton: View {
    var title: String
    var buttonAction: (() -> Void)?
    
    init(
        title: String,
        buttonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        Button {
            if let buttonAction = buttonAction {
                buttonAction()
            }
        } label: {
            Text(title)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.customWhite)
                .padding(.horizontal, 24)
        }
        .background(.customBlack)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CornerButton(
        title: "방만들기",
        buttonAction: {}
    )
}
