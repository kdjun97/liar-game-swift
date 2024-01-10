//
//  Chatting.swift
//  LiarGame
//
//  Created by 김동준 on 1/7/24
//

import Foundation

struct Message: Hashable {
    let nickname: String
    let message: String
    let ipAddress: String
    let isContinuousMessage: Bool
}
