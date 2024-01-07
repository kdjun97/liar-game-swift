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
    private var linkedClientSocket: Socket?
    private var serverCancellable: AnyCancellable?
    private var clientCancellable: AnyCancellable?
    private var isRepeat: Bool = false

    private let bufferSize: Int = 512
    @Published var messageList: [Message] = []
    
    init(
        isServer: Bool = false,
        user: User
    ) {
        self.isServer = isServer
        self.user = user
    }
    
    func setIsRepeat(value: Bool) {
        isRepeat = value
    }
    
    func gameStartButtonTapped() {
        setIsRepeat(value: true)
        if (isServer) {
            startServer()
        } else {
            startClient()
        }
    }
    
    func gameExitButtonTapped() -> Bool {
        if (isServer) {
            // 서버라면, 클라이언트 리스트 정리하고 close, 일단은 지금은 바로 close하는 걸로 구현
            stopServer()
            return true
        } else {
            stopClient()
            return true
        }
    }
    
    func startServer() {
        if let socket = user.socket {
            DispatchQueue.global(qos: .background).async {
                do {
                    repeat {
                        let clientSocket = try socket.acceptClientConnection()
                        print("Accepted Connection from : \(clientSocket.remoteHostname)")
                        self.linkedClientSocket = clientSocket
                        
                        repeat {
                            self.serverCancellable = self.readDataOnServerSocket(socket: clientSocket)
                                .sink(
                                    receiveCompletion: {_ in},
                                    receiveValue: { data in
                                        if (data == "EXIT") {
                                            print("exit 받음")
                                            self.stopServer()
                                        } else {
                                            DispatchQueue.main.async {
                                                self.messageList.append(
                                                    Message(
                                                        nickname: "to parsing",
                                                        message: data,
                                                        ipAddress: "to parsing"
                                                    )
                                                )
                                            }
                                        }
                                    })
                        } while self.linkedClientSocket != nil
                    } while self.isRepeat
                } catch let error {
                    self.alertMessage = "Start Server Error : [\(error)]"
                }
            }
        } else {
            alertMessage = "서버 소켓이 열려있지 않습니다."
            isShowAlert = true
        }
    }
    
    func readDataOnServerSocket(socket: Socket) -> Future<String, Error> {
        var readData = Data(capacity: self.bufferSize)

        return Future { promise in
            do {
                let bytesRead = try socket.read(into: &readData)

                if (bytesRead > 0) {
                    guard let response = String(data: readData, encoding: .utf8) else { return }
                    promise(.success(response))
                    readData.removeAll()
                }
            } catch let error {
                promise(.failure(error))
            }
        }
    }
    
    func startClient() {
        if let socket = user.socket {
            DispatchQueue.global(qos: .background).async {
                repeat {
                    self.clientCancellable = self.readDataOnClientSocket(client: socket)
                        .sink(
                            receiveCompletion: {_ in},
                            receiveValue: { data in
                                if (data == "EXIT") {
                                    print("exit 받음")
                                    self.stopClient()
                                } else {
                                    DispatchQueue.main.async {
                                        self.messageList.append(
                                            Message(
                                                nickname: "to parsing",
                                                message: data,
                                                ipAddress: "to parsing"
                                            )
                                        )
                                    }
                                }
                            })
                } while self.isRepeat
            }
        } else {
            alertMessage = "서버 소켓이 열려있지 않습니다."
            isShowAlert = true
        }
    }
    
    func readDataOnClientSocket(client: Socket) -> Future<String, Error> {
        var readData = Data(capacity: self.bufferSize)

        return Future { promise in
            do {
                let bytesRead = try client.read(into: &readData)

                if (bytesRead > 0) {
                    guard let response = String(data: readData, encoding: .utf8) else { return }
                    promise(.success(response))
                    readData.removeAll()
                }
            } catch let error {
                promise(.failure(error))
            }
        }
    }
    
    func stopServer() {
        if let linkedClientSocket = linkedClientSocket {
            do {
                try linkedClientSocket.write(from: "EXIT")
                self.linkedClientSocket = nil
            } catch {
                // QUIT 못보냈을 경우
            }
            linkedClientSocket.close()
        }
        setIsRepeat(value: false)
        serverCancellable?.cancel()
        serverCancellable = nil
        if let socket = user.socket {
            socket.close()
            user.socket = nil
        }

    }
    
    func stopClient() {
        if let socket = user.socket {
            do {
                try socket.write(from: "EXIT")
            } catch {
                // QUIT 못보냈을 경우
            }
            socket.close()
            user.socket = nil
        }
        setIsRepeat(value: false)
        clientCancellable?.cancel()
        clientCancellable = nil
    }
    
    func sendMessageToServer(_ input: String) {
        do {
            // echoClient.write : 클라 -> 서버
            if let clientSocket = user.socket {
                try clientSocket.write(from: input)
            } else {
                // 서버가 없는 경우
                stopClient()
            }
        } catch {
            print("send Message Exception")
        }
    }
    
    func sendMessageToClient(_ input: String) {
        do {
            if let linkedClientSocket = linkedClientSocket {
                try linkedClientSocket.write(from: input)
            } else {
                print("send Message Error!")
            }
        } catch {
            print("send Message Exception")
        }
    }
}
