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
    @Published var isShowAlert: Bool = false
    
    func setNickName(newValue: String) {
        nickname = newValue
    }
    
    func loadIPTapped() {
        myIPAddress = getIPAddress() ?? "Error!"
    }
    
    func getIPAddress() -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0,
            let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
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
