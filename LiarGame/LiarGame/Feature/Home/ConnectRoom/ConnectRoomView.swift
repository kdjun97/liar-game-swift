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
    @State private var alert: Alert?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNaivgationBar(
                    title: "접속하기",
                    leadingButtonAction: {
                        liarPath.paths.removeLast()
                    }
                )
                
                // Rename image
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
                            connectRoomViewModel.loadIPButtonTapped()
                        },
                        cornerRadius: 4.0,
                        verticalPadding: 10.0
                    )
                    Spacer()
                    CornerButton(
                        title: "접속하기",
                        fontSize: 18,
                        buttonAction: {
                            let isValidNickname = connectRoomViewModel.validateNickName()
                            if (isValidNickname) {
                                let isValidServerIP = connectRoomViewModel.validateServerIP()
                                if (isValidServerIP) {
                                    liarPath.paths.append(
                                        .chatRoom(
                                            isServer: false,
                                            user: User(
                                                serverIP: connectRoomViewModel.serverIPAddress,
                                                myIP: connectRoomViewModel.myIPAddress,
                                                nickname: connectRoomViewModel.nickname
                                            )
                                        )
                                    )
                                } else {
                                    alert = invalidServerIPAlert
                                    connectRoomViewModel.setAlert(isShow: true)
                                }
                            } else {
                                alert = invalidNicknameAlert
                                connectRoomViewModel.setAlert(isShow: true)
                            }
                        },
                        cornerRadius: 4.0,
                        verticalPadding: 10.0
                    )
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear{
            connectRoomViewModel.loadIPButtonTapped()
        }
        .alert(isPresented: $connectRoomViewModel.isShowAlert) {
            alert ?? unKnownErrorAlert
        }
    }
    
    private let invalidNicknameAlert = Alert(
        title: Text("Error"),
        message: Text("Empty nickname!"),
        dismissButton: .destructive(Text("Ok"))
    )
    
    private let invalidServerIPAlert = Alert(
        title: Text("Error"),
        message: Text("Please input Server IP"),
        dismissButton: .destructive(Text("Ok"))
    )
    
    private let unKnownErrorAlert = Alert(
        title: Text("UnKnown Error"),
        message: Text("UnExpected Error!"),
        dismissButton: .destructive(Text("Ok"))
    )
}

#Preview {
    ConnectRoomView()
}
