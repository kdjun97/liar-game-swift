//
//  CreateRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    @StateObject var createRoomViewModel = CreateRoomViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNaivgationBar(
                title: "방만들기",
                leadingButtonAction: {
                    liarPath.paths.removeLast()
                }
            )
            Image("create-room-logo")
                .resizable()
                .scaledToFit()
            
            HStack {
                Text("내 IP : ")
                    .font(.system(size: 24))
                Text("\(createRoomViewModel.myIPAddress)")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            InfoSettingTextField(
                placeHolder: "닉네임 설정",
                text: Binding(
                    get: { createRoomViewModel.nickname },
                    set: { createRoomViewModel.setNickName(newValue: $0) }
                )
            ).padding(.bottom, 24)
            HStack {
                Spacer()
                CornerButton(
                    title: "Load IP",
                    fontSize: 18,
                    buttonAction: {
                        createRoomViewModel.loadIPTapped()
                    },
                    cornerRadius: 4.0,
                    verticalPadding: 10.0
                )
                Spacer()
                CornerButton(
                    title: "방만들기",
                    fontSize: 18,
                    buttonAction: {
                        createRoomViewModel.createRoom()
                    },
                    cornerRadius: 4.0,
                    verticalPadding: 10.0
                )
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    CreateRoomView()
}
