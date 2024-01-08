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
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    private var serverSocket: Socket?
    private var clientSocket: Socket?
    private var linkedClientSocket: Socket?
    
    private var serverCancellable: AnyCancellable?
    private var clientCancellable: AnyCancellable?
    private var isRepeat: Bool = false

    private let port: Int = 12345
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
        do {
            serverSocket = try Socket.create(family: .inet)
            guard let server = serverSocket else {
                setAlert(title: "Server Error", message: "Server Socket Create Failed!", active: true)
                return
            }
            
            try server.listen(on: port)
            
            iterativeServer()
        } catch let error {
            setAlert(title: "Unknown", message: error.localizedDescription, active: true)
        }
    }
    
    func iterativeServer() {
        setIsRepeat(value: true)

        if let socket = serverSocket {
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
                    self.setAlert(title: "Server Error", message: error.localizedDescription, active: true)
                }
            }
        } else {
            setAlert(title: "Server Error", message: "서버 소켓이 열려있지 않습니다.", active: true)
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
        do {
            clientSocket = try Socket.create(family: .inet)
            guard let client = clientSocket else {
                setAlert(title: "Client Error", message: "Client Socket Create Failed!", active: true)
                return
            }
            try client.connect(to: user.serverIP, port: Int32(port))
            handleClientData()
        } catch let error {
            setAlert(title: "Unknown", message: error.localizedDescription, active: true)
        }
    }
    
    func handleClientData() {
        setIsRepeat(value: true)
        
        if let socket = clientSocket {
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
            setAlert(title: "Socket Error", message: "서버 혹은 클라이언트 소켓 연결을 확인해주세요", active: true)
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
                linkedClientSocket.close()
                self.linkedClientSocket = nil
            } catch {
                // QUIT 못보냈을 경우
            }
        }
        setIsRepeat(value: false)
        
        serverCancellable?.cancel()
        serverCancellable = nil
        
        if let server = serverSocket {
            server.close()
            self.serverSocket = nil
        }
    }
    
    func stopClient() {
        if let client = clientSocket {
            do {
                try client.write(from: "EXIT")
            } catch {
                // QUIT 못보냈을 경우
            }
            client.close()
            self.clientSocket = nil
        }
        setIsRepeat(value: false)
        clientCancellable?.cancel()
        clientCancellable = nil
    }
    
    func sendMessage(_ message: String) {
        if (isServer) {
            sendMessageToClient(message)
        } else {
            sendMessageToServer(message)
        }
    }
    
    func sendMessageToServer(_ message: String) {
        do {
            if let clientSocket = clientSocket {
                try clientSocket.write(from: message)
            } else {
                setAlert(title: "Error", message: "연결된 서버 혹은 클라이언트 소켓이 없습니다.", active: true)
            }
        } catch {
            setAlert(title: "Error", message: "[Client -> Server] send message failed", active: true)
        }
    }
    
    func sendMessageToClient(_ message: String) {
        do {
            if let linkedClientSocket = linkedClientSocket {
                try linkedClientSocket.write(from: message)
            } else {
                setAlert(title: "Error", message: "연결된 클라이언트가 없습니다", active: true)
            }
        } catch {
            setAlert(title: "Error", message: "[Server -> Client] send message failed", active: true)
        }
    }
    
    func setAlert(title: String, message: String, active: Bool) {
        alertTitle = title
        alertMessage = message
        isShowAlert = active
    }
}
