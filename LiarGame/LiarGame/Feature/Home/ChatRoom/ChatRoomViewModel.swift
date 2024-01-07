//
//  ChatRoomViewModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/6/24
//

import Foundation
import Combine
import Socket

class ChatRoomViewModel: ObservableObject {
    var isServer: Bool
    @Published var user: User
    @Published var isShowAlert: Bool = false
    @Published var alertMessage: String = ""

    init(
        isServer: Bool = false,
        user: User
    ) {
        self.isServer = isServer
        self.user = user
    }
    
    func gameStartButtonTapped() {
        if (isServer) {
            // 게임 start 로직
        } else {
            alertMessage = "방장만 게임 시작 가능!"
            isShowAlert = true
        }
    }
    
    func gameExitButtonTapped() -> Bool {
        if (isServer) {
            // 서버라면, 클라이언트 리스트 정리하고 close, 일단은 지금은 바로 close하는 걸로 구현
            user.socket.close()
            return true
        } else {
            user.socket.close()
            return true
        }
    }
}
