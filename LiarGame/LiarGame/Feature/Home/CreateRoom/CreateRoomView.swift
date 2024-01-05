//
//  CreateRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    
    var body: some View {
        VStack {
            CustomNaivgationBar(
                title: "방만들기",
                leadingButtonAction: {
                    liarPath.paths.removeLast()
                }
            )
            Spacer()
        }
    }
}

#Preview {
    CreateRoomView()
}
