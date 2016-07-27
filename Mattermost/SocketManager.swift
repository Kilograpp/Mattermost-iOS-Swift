//
//  SocketManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Starscream
private struct NotificationKeys {
    static let ChannelIdentifier = "channel_id"
    static let TeamIdentifier = "team_id"
    static let UserIdentifier = "user_id"
    static let Identifier = "id"
    static let Post = "post"
    static let Action = "action"
    static let Properties = "props"
    static let PendingPostIdentifier = "pending_post_id"
}

enum ChannelAction: String {
    case Typing = "typing"
    case ChannelView = "channel_view"
    case Posted = "posted"
    case Unknown
}

@objc class SocketManager: NSObject {
    static let sharedInstance = SocketManager()
    
    private lazy var socket: WebSocket = {
        let webSocket = WebSocket(url: Api.sharedInstance.baseURL().URLByAppendingPathComponent(User.socketPathPattern()).URLWithScheme(.WSS)!)
        webSocket.delegate = self
        webSocket.setCookie(Api.sharedInstance.cookie())
        return webSocket
    }()
}

private protocol Interface {
    func setNeedsConnect()
    func disconnect()
}

private protocol StateControl {
    func shouldConnect() -> Bool
}

extension SocketManager: WebSocketDelegate{
    func websocketDidConnect(socket: WebSocket) {
        
    }
    func websocketDidReceiveData(socket: Starscream.WebSocket, data: NSData) {
        
    }
    func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        if error != nil {
            setNeedsConnect()
        }
    }
    func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        
    }
}

extension SocketManager: Interface {
    func setNeedsConnect() {
        if shouldConnect() {
            self.socket.connect()
        }
    }
    func disconnect() {
        socket.disconnect()
    }
}

extension SocketManager: StateControl {
    private func shouldConnect() -> Bool{
        return !self.socket.isConnected
    }
}