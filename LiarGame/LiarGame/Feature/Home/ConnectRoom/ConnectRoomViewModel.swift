//
//  ConnectRoomViewModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/5/24
//

import Foundation

class ConnectRoomViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var myIPAddress: String = "-"
    @Published var serverIPAddress: String = ""
    @Published var isShowAlert: Bool = false
    
    func setNickName(newValue: String) {
        nickname = newValue
    }
    
    func setServerIPAddress(newValue: String) {
        serverIPAddress = newValue
    }
    
    func loadIPButtonTapped() {
        myIPAddress = DeviceManager.shared.getIPAddress() ?? "Error!"
    }
    
    func setAlert(isShow: Bool) {
        isShowAlert = isShow
    }
    
    func validateNickName() -> Bool {
        if (nickname.isEmpty) {
            return false
        } else {
            return true
        }
    }
}
