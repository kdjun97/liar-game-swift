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
                                let isValidIPAddress = createRoomViewModel.myIPAddress.checkIpValidation(regex: .ipv4)
                                if (isValidIPAddress) {
                                    liarPath.paths.append(
                                        .chatRoom(
                                            isServer: true,
                                            serverIp: createRoomViewModel.myIPAddress,
                                            myIpAddress: createRoomViewModel.myIPAddress,
                                            nickname: createRoomViewModel.nickname
                                        )
                                    )
                                } else {
                                    alert = invalidIpAddress
                                    createRoomViewModel.setAlert(isShow: true)
                                }
                            } else {
                                alert = invalidNicknameAlert
                                createRoomViewModel.setAlert(isShow: true)
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
        .onAppear {
            createRoomViewModel.loadIPTapped()
        }
        .alert(isPresented: $createRoomViewModel.isShowAlert) {
            alert ?? unKnownErrorAlert
        }
    }
    
    private let invalidNicknameAlert = Alert(
        title: Text("Error"),
        message: Text("Empty nickname!"),
        dismissButton: .destructive(Text("Ok"))
    )
    
    private let invalidIpAddress = Alert(
        title: Text("Error"),
        message: Text("Invalid Your IP Address.\nPlease Re-connect WIFI or check your WIFI is connected.\nIf you've followed the guid above, press the \"Load IP\" button and re-check correct IP Address format."),
        dismissButton: .destructive(Text("Ok"))
    )
    
    private let unKnownErrorAlert = Alert(
        title: Text("UnKnown Error"),
        message: Text("UnExpected Error!"),
        dismissButton: .destructive(Text("Ok"))
    )
}

#Preview {
    CreateRoomView()
}
