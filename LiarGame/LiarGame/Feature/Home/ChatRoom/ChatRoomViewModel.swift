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
    private var linkedClientSocket: [Socket?] = []
    
    private var serverCancellable: AnyCancellable?
    private var clientCancellable: AnyCancellable?
    private var isRepeat: Bool = false
    private var isAcceptRepeat: Bool = false

    private let port: Int = 12345
    private let bufferSize: Int = 512
    private let exitMessage: String = "[EXITMESSAGE]"
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
            stopServer()
            return true
        } else {
            stopClient()
            return true
        }
    }
    
    func startServer() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                self.serverSocket = try Socket.create(family: .inet)
                guard let server = self.serverSocket else {
                    self.setAlert(title: "Server Error", message: "Server Socket Create Failed!", active: true)
                    return
                }
                
                try server.listen(on: self.port)
                
                self.isAcceptRepeat = true
                repeat {
                    let clientSocket = try server.acceptClientConnection()
                    print("Accepted Connection from : \(clientSocket.remoteHostname)")
                    self.linkedClientSocket.append(clientSocket)
                    
                    self.iterativeServerAccept(socket: clientSocket)
                } while self.isAcceptRepeat
                
                
            } catch let error {
                self.setAlert(title: "Unknown", message: error.localizedDescription, active: true)
            }
        }
    }
    
    func iterativeServerAccept(socket: Socket) {
        DispatchQueue.global(qos: .background).async {
            do {
                self.setIsRepeat(value: true)

                repeat {
                    self.serverCancellable = self.readDataOnServerSocket(socket: socket)
                        .sink(
                            receiveCompletion: {_ in},
                            receiveValue: { data in
                                if (data.contains(self.exitMessage)) {
                                    self.stopServer()
                                } else {
                                    print(data)
                                    if let splitedMessage = self.splitStringMessage(message: data) {
                                        self.echoMessageToLinkedClientSockets(message: splitedMessage)
                                        DispatchQueue.main.async {
                                            self.messageList.append(
                                                Message(
                                                    nickname: splitedMessage.nickname,
                                                    message: splitedMessage.message,
                                                    ipAddress: splitedMessage.ipAddress,
                                                    isContinuousMessage: splitedMessage.isContinuousMessage
                                                )
                                            )
                                        }
                                    }
                                }
                            })
                } while self.isRepeat
            } catch let error {
                self.setAlert(title: "Server Error", message: error.localizedDescription, active: true)
            }
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
    
    func echoMessageToLinkedClientSockets(message: Message) {
        self.linkedClientSocket.forEach { clientSocket in
            if let clientSocket = clientSocket {
                if (clientSocket.remoteHostname != message.ipAddress) {
                    let message = "\(message.nickname)\\\(message.message)\\\(message.ipAddress)"
                    do {
                        try clientSocket.write(from: message)
                    } catch {
                        setAlert(title: "Error", message: "[Server -> Client] send message failed", active: true)
                    }
                }
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
                                if (data == self.exitMessage) {
                                    print("exit 받음")
                                    self.stopClient()
                                } else {
                                    if let splitedMessage = self.splitStringMessage(message: data) {
                                        DispatchQueue.main.async {
                                            self.messageList.append(
                                                Message(
                                                    nickname: splitedMessage.nickname,
                                                    message: splitedMessage.message,
                                                    ipAddress: splitedMessage.ipAddress,
                                                    isContinuousMessage: splitedMessage.isContinuousMessage
                                                )
                                            )
                                        }
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
        for (index, socket) in linkedClientSocket.enumerated() {
            if let socket = socket {
                do {
                    try socket.write(from: exitMessage)
                    socket.close()
                    linkedClientSocket[index] = nil
                } catch {
                    // QUIT 못보냈을 경우
                }
            }
        }
        
        setIsRepeat(value: false)
        isAcceptRepeat = false
        
        serverCancellable?.cancel()
        serverCancellable = nil
        
        linkedClientSocket.removeAll()
        
        if let server = serverSocket {
            server.close()
            self.serverSocket = nil
        }
    }
    
    func stopClient() {
        if let client = clientSocket {
            do {
                let message = "\(exitMessage)/\(user.myIP)"
                try client.write(from: exitMessage)
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
    
    func sendMessage(_ message: String) -> Bool {
        if (isServer) {
            return sendMessageToClient(message)
        } else {
            return sendMessageToServer(message)
        }
    }
    
    func sendMessageToServer(_ message: String) -> Bool {
        do {
            if let clientSocket = clientSocket {
                let message = "\(user.nickname)\\\(message)\\\(user.myIP)"
                try clientSocket.write(from: message)
                if let splitedMessage = splitStringMessage(message: message) {
                    messageList.append(splitedMessage)
                }
                return true
            } else {
                setAlert(title: "Error", message: "연결된 서버 혹은 클라이언트 소켓이 없습니다.", active: true)
                return false
            }
        } catch {
            setAlert(title: "Error", message: "[Client -> Server] send message failed", active: true)
            return false
        }
    }
    
    func sendMessageToClient(_ message: String) -> Bool {
        if linkedClientSocket.isEmpty {
            setAlert(title: "Error", message: "연결된 클라이언트가 없습니다", active: true)
            return false
        } else {
            do {
                let message = "\(user.nickname)\\\(message)\\\(user.myIP)"
                try linkedClientSocket.forEach { socket in
                    if let socket = socket {
                        try socket.write(from: message)
                    }
                }
                if let splitedMessage = splitStringMessage(message: message) {
                    messageList.append(splitedMessage)
                }
                return true
            } catch {
                setAlert(title: "Error", message: "[Server -> Client] send message failed", active: true)
                return false
            }
        }
    }
    
    func setAlert(title: String, message: String, active: Bool) {
        alertTitle = title
        alertMessage = message
        isShowAlert = active
    }
    
    func splitStringMessage(message: String) -> Message? {
        let splitList = message.split(separator: "\\")
        if (splitList.count == 3) {
            return Message(
                nickname: String(splitList[0]),
                message: String(splitList[1]),
                ipAddress: String(splitList[2]),
                isContinuousMessage: checkMessageContinuous(currentIpAddress: String(splitList[2]))
            )
        } else {
            return nil
        }
    }
    
    func checkMessageContinuous(currentIpAddress: String) -> Bool {
        if (messageList.isEmpty) {
            return false
        } else {
            if let message = messageList.last {
                return message.ipAddress == currentIpAddress
            } else {
                return false
            }
        }
    }
}
