//
//  UserModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/6/24
//

import Foundation
import Socket

struct User: Hashable {
    let socket: Socket
    let serverIP: String
    let myIP: String
}
