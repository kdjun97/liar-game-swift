//
//  CreateRoomViewModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/5/24
//

import Foundation

class CreateRoomViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var myIPAddress: String = "-"
    
    func setNickName(newValue: String) {
        nickname = newValue
    }
    
    func loadIPTapped() {
        
    }
    
    func createRoom() {
        
    }
}
