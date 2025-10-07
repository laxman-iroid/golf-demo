//
//  SocketIOManager.swift
//  Kinship
//
//  Created by iMac on 03/05/24.
//

import Foundation
import SocketIO

class SocketHelper {
    static let shared = SocketHelper()
//
    let manager:SocketManager?
    var socket: SocketIOClient!
    
    private init() {
        manager = SocketManager(socketURL: URL(string:socketServerUrl)!, config: [.log(true), .compress,.connectParams(["token" : Utility.getAccessToken() ?? "" ]), .reconnects(true)])
//        manager = SocketManager(socketURL: URL(string: socketServerUrl)!, config: [.log(true), .compress])
//        manager = SocketManager(socketURL: URL(string: socketServerUrl)!, config: [.log(true), .compress, .reconnects(true), .extraHeaders(["Authorization": "\(Utility.getAccessToken() ?? "")"])])
        socket = manager?.defaultSocket
    }
    
    func connectSocket(completion: @escaping(Bool) -> () ) {
        self.disconnectSocket()
        socket.on(clientEvent: .connect) {[weak self] (data, ack) in
            print(" ==== socket connected ==== ")
//            Utility.successAlert(message: "==== socket connected ====")
            self?.socket.removeAllHandlers()
            completion(true)
        }
        socket.connect()
    }
    func disconnectSocket() {
        socket.removeAllHandlers()
        socket.disconnect()
        print("==== socket Disconnected ====")
//        Utility.showAlert(message: "==== socket Disconnected ====")
    }
    
    func checkConnection() -> Bool {
        if socket.status == .connected {
            return true
        }
        return false
    }
    
    enum Events {
        case updateUserLocation
//        case roomConnected
//        case sendMessage
//        case newMessage
        
        var emitterName: String {
            switch self {
            case .updateUserLocation:
                return "update_user_location"       // update User Location (Emit)
//            case .roomConnected:
//                return "roomConnected"    // Room Connected (listen)
//            case .sendMessage:
//                return "sendMessage"      // Send New Message (Emit)
//            case .newMessage:
//                return "newMessage"         // Get New Message (listen)
            }
        }
        
        func emit(params: [String : Any], success: @escaping () -> ()) {
            SocketHelper.shared.socket?.emit(emitterName, params) {
                success()
            }
        }
        
        func listen(completion: @escaping (Any) -> Void) {
            SocketHelper.shared.socket?.on(emitterName) { (response, emitter) in
                completion(response.first as Any)
            }
        }
        
        func off() {
            SocketHelper.shared.socket?.off(emitterName)
        }
    }
}
