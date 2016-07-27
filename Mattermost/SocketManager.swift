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


extension SocketManager {
    func postExistsWithIdentifier(identifier: String, pendingIdentifier: String) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "%K == %@ || %K == %@", PostAttributes.identifier.rawValue, identifier, PostAttributes.privatePendingId.rawValue, pendingIdentifier)
        return realm.objects(Post).filter(predicate).first != nil
    }
    private func handleIncomingMessage(text: String) {
        let dictionary = text.toDictionary()!
        let userId     = dictionary[NotificationKeys.UserIdentifier] as! String
        let action     = dictionary[NotificationKeys.Action] as! String
        let channelId  = dictionary[NotificationKeys.ChannelIdentifier] as! String
        let postString = dictionary[NotificationKeys.Properties]![NotificationKeys.Post] as? NSString
        
        if let postDictionary = postString?.toDictionary() {
            let postPendingIdentifier = postDictionary[NotificationKeys.PendingPostIdentifier] as! String
            let postIdentifier = postDictionary[NotificationKeys.Identifier] as! String
            if !postExistsWithIdentifier(postIdentifier, pendingIdentifier: postPendingIdentifier) {
                
                let post = Post()
                post.identifier = (postDictionary[NotificationKeys.Identifier] as! String)
                post.privateChannelId = channelId
                
                Api.sharedInstance.updatePost(post, completion: { (error) in
                    self.notifyWithChannelIdentifier(channelId, userIdentifier: userId, action: ChannelAction(rawValue: action))
                })
            }
        } else {
            notifyWithChannelIdentifier(channelId, userIdentifier: userId, action: ChannelAction(rawValue: action))
        }

    }
    
    private func notifyWithChannelIdentifier(channelIdentifier: String!, userIdentifier: String!, action: ChannelAction!) {
        let notificationName = ActionsNotification.notificationNameForChannelIdentifier(channelIdentifier)
        let notification = ActionsNotification(userIdentifier: userIdentifier, action: action)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: notification)
        
    }
}

