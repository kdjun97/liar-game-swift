//
//  UserModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/6/24
//

import Foundation

struct User: Hashable {
    let serverIP: String
    let myIP: String
    let nickname: String
}
