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
                                let (state, clientSocket) = connectRoomViewModel.connectRoom()
                                if let clientSocket = clientSocket {
                                    // TODO : Navigate To Chatting Room With clientSocket
                                    liarPath.paths.append(.chatRoom)
                                } else {
                                    alert = getAlert(state: state)
                                    if let _ = alert {
                                        connectRoomViewModel.setAlert(isShow: true)
                                    }
                                }
                            } else {
                                alert = getAlert(state: .nickNameError)
                                if let _ = alert {
                                    connectRoomViewModel.setAlert(isShow: true)
                                }
                            }
                        },
                        cornerRadius: 4.0,
                        verticalPadding: 10.0
                    )
                    Spacer()
                }
                Spacer()
            }
        }.alert(isPresented: $connectRoomViewModel.isShowAlert) {
            alert ?? unKnownErrorAlert
        }
    }
    
    private func getAlert(state: ConnectRoomState) -> Alert? {
        switch (state) {
        case .success: return nil
        case .nickNameError: return nickNameErrorAlert
        case .connectFail: return connectServerErrorAlert
        case .unKnown: return unKnownErrorAlert
        }
    }
    
    private let nickNameErrorAlert = Alert(
        title: Text("Error"),
        message: Text("Empty nickname!"),
        dismissButton: .default(Text("Ok"))
    )
    
    private let connectServerErrorAlert = Alert(
        title: Text("Error"),
        message: Text("Connect Server Failed!"),
        dismissButton: .default(Text("Ok"))
    )
    
    private let unKnownErrorAlert = Alert(
        title: Text("UnKnown Error"),
        message: Text("UnExpected Error!"),
        dismissButton: .default(Text("Ok"))
    )
}

#Preview {
    ConnectRoomView()
}
