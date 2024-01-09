//
//  String+Extensions.swift
//  LiarGame
//
//  Created by 김동준 on 1/9/24
//

extension String {
    func checkIpValidation(regex: RegexCase) -> Bool {
        if self.isEmpty {
            return false
        }
        if let _ = self.range(of: regex.rawValue, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }
}
