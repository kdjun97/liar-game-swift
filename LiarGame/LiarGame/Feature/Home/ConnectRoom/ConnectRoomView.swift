//
//  ConnectRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct ConnectRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    @StateObject private var connectRoomViewModel = ConnectRoomViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNaivgationBar(
                title: "접속하기",
                leadingButtonAction: {
                    liarPath.paths.removeLast()
                }
            )
            
            Image("logo2")
                .resizable()
                .scaledToFit()
            
            HStack {
                Text("내 IP : ")
                    .font(.system(size: 24))
                Text("\(connectRoomViewModel.myIPAddress)")
                    .font(.system(size: 24))
            }.padding(.bottom, 12)
            
            InfoSettingTextField(
                placeHolder: "닉네임 설정",
                text: Binding(
                    get: { connectRoomViewModel.nickname },
                    set: { connectRoomViewModel.setNickName(newValue: $0) }
                )
            ).padding(.bottom, 12)
            
            InfoSettingTextField(
                placeHolder: "서버 IP 주소",
                text: Binding(
                    get: { connectRoomViewModel.serverIPAddress },
                    set: { connectRoomViewModel.setServerIPAddress(newValue: $0) }
                )
            ).padding(.bottom, 24)
            
            HStack {
                Spacer()
                CornerButton(
                    title: "Load IP",
                    fontSize: 18,
                    buttonAction: {
                        connectRoomViewModel.loadIPTapped()
                    },
                    cornerRadius: 4.0,
                    verticalPadding: 10.0
                )
                Spacer()
                CornerButton(
                    title: "접속하기",
                    fontSize: 18,
                    buttonAction: {
                        connectRoomViewModel.connectRoom()
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
    ConnectRoomView()
}
