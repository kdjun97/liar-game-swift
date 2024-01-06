//
//  CreateRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import SwiftUI

struct CreateRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    @StateObject private var createRoomViewModel = CreateRoomViewModel()
    @State private var alert: Alert?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNaivgationBar(
                    title: "방만들기",
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
                    Text("\(createRoomViewModel.myIPAddress)")
                        .font(.system(size: 24))
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
                            let isValidNickname = createRoomViewModel.validateNickName()
                            if (isValidNickname) {
                                let (state, serverSocket) = createRoomViewModel.createRoom()
                                if let serverSocket = serverSocket {
                                    liarPath.paths.append(
                                        .chatRoom(
                                            isServer: true,
                                            user: User(
                                                socket: serverSocket,
                                                serverIP: createRoomViewModel.myIPAddress,
                                                myIP: createRoomViewModel.myIPAddress,
                                                nickname: createRoomViewModel.nickname
                                            )
                                        )
                                    )
                                } else {
                                    alert = getAlert(state: state)
                                    if let _ = alert {
                                        createRoomViewModel.setAlert(isShow: true)
                                    }
                                }
                            } else {
                                alert = getAlert(state: .nickNameError)
                                if let _ = alert {
                                    createRoomViewModel.setAlert(isShow: true)
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
        }.alert(isPresented: $createRoomViewModel.isShowAlert) {
            alert ?? unKnownErrorAlert
        }
    }
    
    private let nickNameErrorAlert = Alert(
        title: Text("Error"),
        message: Text("Empty nickname!"),
        dismissButton: .default(Text("Ok"))
    )
    
    private let createServerErrorAlert = Alert(
        title: Text("Socket Create Error"),
        message: Text("Server Socket Create Failed!"),
        dismissButton: .default(Text("Ok"))
    )
    
    private let unKnownErrorAlert = Alert(
        title: Text("UnKnown Error"),
        message: Text("UnExpected Error!"),
        dismissButton: .default(Text("Ok"))
    )
    
    private func getAlert(state: CreateRoomState) -> Alert? {
        switch (state) {
        case .success: return nil
        case .nickNameError: return nickNameErrorAlert
        case .createFail: return createServerErrorAlert
        case .unKnown: return unKnownErrorAlert
        }
    }
}

#Preview {
    CreateRoomView()
}
