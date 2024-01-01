//
//  ConnectRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct ConnectRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    
    var body: some View {
        CustomNaivgationBar(
            title: "접속하기",
            leadingButtonAction: {
                liarPath.paths.removeLast()
            }
        )
        Spacer()
    }
}

#Preview {
    ConnectRoomView()
}
