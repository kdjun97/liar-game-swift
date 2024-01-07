//
//  CustomNaivgationBar.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CustomNaivgationBar: View {
    var title: String
    var isShowBackButton: Bool
    var leadingButtonAction: (() -> Void)?
    
    init(
        title: String,
        isShowBackButton: Bool = true,
        leadingButtonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.isShowBackButton = isShowBackButton
        self.leadingButtonAction = leadingButtonAction
    }
    
    var body: some View {
        ZStack {
            HStack {
                Button {
                    if let leadingButtonAction = leadingButtonAction {
                        leadingButtonAction()
                    }
                } label: {
                    Image("back")
                        .renderingMode(.template)
                        .foregroundColor(.customWhite)
                }.padding(.leading, 12)
                Spacer()
            }
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(.customWhite)
        }.padding(.vertical, 12).background(.customBlack)
    }
}

#Preview {
    CustomNaivgationBar(
        title: "예시"
    )
}
