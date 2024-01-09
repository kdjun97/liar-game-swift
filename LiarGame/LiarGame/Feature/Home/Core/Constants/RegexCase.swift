//
//  RegexCase.swift
//  LiarGame
//
//  Created by 김동준 on 1/9/24
//

// IPv6나 다른 케이스를 위해 enum 으로 생성
enum RegexCase: String {
    case ipv4 = #"^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$"#
}
