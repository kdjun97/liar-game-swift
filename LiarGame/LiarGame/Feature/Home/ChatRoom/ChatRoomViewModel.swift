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
    
    init(
        isServer: Bool = false,
        user: User
    ) {
        self.isServer = isServer
        self.user = user
    }
}
