//
//  ChatRoomView.swift
//  LiarGame
//
//  Created by 김동준 on 1/6/24
//

import Foundation
import SwiftUI

struct ChatRoomView: View {
    @EnvironmentObject private var liarPath: LiarPath
    @StateObject var chatRoomViewModel : ChatRoomViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GameStatusBar(chatRoomViewModel: chatRoomViewModel)
                Divider()
                    .frame(height: 1)
                Text("Now, In the Chat Room")
                Spacer()
            }
        }.alert(isPresented: $chatRoomViewModel.isShowAlert) {
            Alert(
                title: Text("Error"),
                message: Text(chatRoomViewModel.alertMessage),
                dismissButton: .destructive(Text("Ok"))
            )
        }
    }
}

private struct GameStatusBar: View {
    @EnvironmentObject private var liarPath: LiarPath
    @ObservedObject var chatRoomViewModel : ChatRoomViewModel
    
    fileprivate var body: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                IPAddressInfoView(
                    title: "서버",
                    ipAddress: chatRoomViewModel.user.serverIP
                ).padding(.bottom, 4)
                IPAddressInfoView(
                    title: "나",
                    ipAddress: chatRoomViewModel.user.myIP
                )
            }
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                SystemButton(
                    title: "게임시작",
                    buttonAction: {
                        chatRoomViewModel.gameStartButtonTapped()
                    }
                )
                Spacer()
                SystemButton(
                    title: "나가기",
                    buttonAction: {
                        let isSuccess = chatRoomViewModel.gameExitButtonTapped()
                        if (isSuccess) {
                            liarPath.paths.removeAll()
                        }
                    }
                )
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct IPAddressInfoView: View {
    let title: String
    let ipAddress: String
    
    fileprivate init(
        title: String,
        ipAddress: String
    ) {
        self.title = title
        self.ipAddress = ipAddress
    }
    
    fileprivate var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .lineLimit(1)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(.customPink)
                .cornerRadius(12)
            Text(ipAddress)
                .lineLimit(1)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black, lineWidth: 0.1)
        )
    }
}

private struct SystemButton: View {
    let title: String
    let buttonAction: () -> Void
    
    fileprivate var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(title)
                .foregroundColor(.black)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(.customPink)
        .cornerRadius(12)
    }
}
