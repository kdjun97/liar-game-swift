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
                ScrollView {
                    ForEach(chatRoomViewModel.messageList, id:\.self) { message in
                        ChattingMessage(
                            myIpAddress: chatRoomViewModel.user.myIP,
                            nickname: message.nickname,
                            message: message.message,
                            ipAddress: message.ipAddress
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                ChattingTextField(chatRoomViewModel: chatRoomViewModel)
            }
        }
        .onAppear {
            UIApplication.shared.hideKeyboard()
        }
        .alert(isPresented: $chatRoomViewModel.isShowAlert) {
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
                    title: "본인",
                    ipAddress: chatRoomViewModel.user.myIP
                )
            }
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                SystemButton(
                    title: chatRoomViewModel.isServer ? "게임시작" : "접속하기",
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

private struct ChattingMessage: View {
    let myIpAddress: String
    let nickname: String
    let message: String
    let ipAddress: String
    
    init(
        myIpAddress: String,
        nickname: String,
        message: String,
        ipAddress: String
    ) {
        self.myIpAddress = myIpAddress
        self.nickname = nickname
        self.message = message
        self.ipAddress = ipAddress
    }
    
    fileprivate var body: some View {
        if (myIpAddress == ipAddress) {
            mySelfMessage()
        } else {
            audienceMessage()
        }
    }
    
    func mySelfMessage() -> some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: 14))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.customPink)
                .cornerRadius(10)
        }
        .padding(.trailing, 8)
        .padding(.leading, 36)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
    
    func audienceMessage() -> some View {
        HStack(alignment:.top) {
            Image("logo2")
                .resizable()
                .frame(width: 30, height: 30)
                .scaledToFit()
                .clipShape(.circle)
                .overlay(Circle().stroke(Color.black, lineWidth: 0.3))
                .padding(.leading, 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(nickname)
                    .font(.system(size: 14))
                    .padding(.vertical, 6)
                    .cornerRadius(10)
                Text(message)
                    .font(.system(size: 14))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.customPink)
                    .cornerRadius(10)
            }
        }
        .padding(.trailing, 36)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct ChattingTextField: View {
    @State private var text: String = ""
    @ObservedObject private var chatRoomViewModel: ChatRoomViewModel
    
    init(chatRoomViewModel: ChatRoomViewModel) {
        self.chatRoomViewModel = chatRoomViewModel
    }
    
    fileprivate var body: some View {
        HStack(spacing: 0) {
            TextField(
                "",
                text: $text
            )
            .font(.system(size: 18))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.customWhite)
            .cornerRadius(12)
            Spacer()
            Button {
                let isSendMessage = chatRoomViewModel.sendMessage(text)
                if (isSendMessage) {
                    text = ""
                }
            } label: {
                Image("send").padding(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.customPink)
    }
}

extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

#Preview {
    ChatRoomView(chatRoomViewModel: ChatRoomViewModel(user: User(serverIP: "1232", myIP: "123", nickname: "손흥민")))
}
