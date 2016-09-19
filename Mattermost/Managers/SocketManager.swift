//
//  SocketManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Starscream
import RealmSwift

private protocol Interface: class {
    func sendNotificationAboutAction(action: ChannelAction, channel: Channel)
    func setNeedsConnect()
    func disconnect()
}

@objc final class SocketManager: NSObject {
    static let sharedInstance = SocketManager()
    private var lastNotificationDate: NSDate?
    private lazy var socket: WebSocket = {
        let webSocket = WebSocket(url: Api.sharedInstance.baseURL().URLByAppendingPathComponent(UserPathPatternsContainer.socketPathPattern()).URLWithScheme(.WSS)!)
        webSocket.delegate = self
        webSocket.setCookie(Api.sharedInstance.cookie())
        return webSocket
    }()
}

private struct NotificationKeys {
    static let ChannelIdentifier = "channel_id"
    static let TeamIdentifier = "team_id"
    static let UserIdentifier = "user_id"
    static let Identifier = "id"
    static let Post = "post"
    static let Action = "action"
    static let Properties = "props"
    static let PendingPostIdentifier = "pending_post_id"
    static let State = "state"
}

enum ChannelAction: String {
    case Typing = "typing"
    case ChannelView = "channel_viewed"
    case Posted = "posted"
    case UserAdded = "user_added"
    case Unknown
}

private protocol Notifications: class {
    func publishBackendNotificationAboutAction(action: ChannelAction, channel: Channel)
    func publishLocalNotificationWithChannelIdentifier(channelIdentifier: String, userIdentifier: String, action: ChannelAction)
}

private protocol StateControl: class {
    func shouldConnect() -> Bool
    func shouldSendNotification() -> Bool
}

private protocol Validation: class {
    func postExistsWithIdentifier(identifier: String, pendingIdentifier: String) -> Bool
}

private protocol MessageHandling: class {
    func handleIncomingMessage(text: String)
}


// MARK: - WebSocket Delegate
extension SocketManager: WebSocketDelegate{
    func websocketDidConnect(socket: WebSocket) {
        NSLog("Socket did connect")
    }
    func websocketDidReceiveData(socket: Starscream.WebSocket, data: NSData) {}
    func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        NSLog("Socket did disconnect")
        if error != nil {
            setNeedsConnect()
        }
    }
    func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        self.handleIncomingMessage(text)
    }
}

// MARK: - Interface Methods
extension SocketManager: Interface {
    func sendNotificationAboutAction(action: ChannelAction, channel: Channel) {
        self.publishBackendNotificationAboutAction(action, channel: channel)
    }
    func setNeedsConnect() {
        if shouldConnect() {
            self.socket.connect()
        }
    }
    func disconnect() {
        socket.disconnect(forceTimeout: 0)
    }
}


//MARK: - Incoming Messages Handling
extension SocketManager: MessageHandling {
    private func handleIncomingMessage(text: String) {
        let dictionary = text.toDictionary()!
        let userId     = dictionary[NotificationKeys.UserIdentifier] as! String
        let action     = dictionary[NotificationKeys.Action] as! String
        let channelId  = dictionary[NotificationKeys.ChannelIdentifier] as! String
        let postString = dictionary[NotificationKeys.Properties]![NotificationKeys.Post] as? NSString
        
        if let postDictionary = postString?.toDictionary() {
            let postPendingIdentifier = postDictionary[NotificationKeys.PendingPostIdentifier] as! String
            let postIdentifier        = postDictionary[NotificationKeys.Identifier] as! String
            
            if !postExistsWithIdentifier(postIdentifier, pendingIdentifier: postPendingIdentifier) {
                
                let post = Post()
                post.identifier = (postDictionary[NotificationKeys.Identifier] as! String)
                post.channelId = channelId
                
                Api.sharedInstance.updatePost(post, completion: { (error) in
                    self.publishLocalNotificationWithChannelIdentifier(channelId, userIdentifier: userId, action: ChannelAction(rawValue: action)!)
                })
            }
        } else {
            self.publishLocalNotificationWithChannelIdentifier(channelId, userIdentifier: userId, action: ChannelAction(rawValue: action) ?? ChannelAction.Unknown)
        }

    }
}

//MARK: - Notifications
extension SocketManager: Notifications {
    func publishBackendNotificationAboutAction(action: ChannelAction, channel: Channel) {
        if shouldSendNotification() {
            let parameters: [String: JSON] = [
                NotificationKeys.ChannelIdentifier : JSON(stringLiteral: channel.identifier!),
                NotificationKeys.TeamIdentifier    : JSON(stringLiteral: DataManager.sharedInstance.currentTeam!.identifier!),
                NotificationKeys.Action            : JSON(stringLiteral: action.rawValue),
                NotificationKeys.State             : JSON(SocketNotificationState()),
                NotificationKeys.Properties        : JSON(["parent_id" : ""])
            ]
//            let message = "{\"channel_id\":\"o36ktmifaf88dy9e87d9f5n3da\",\"action\":\"typing\",\"props\":{\"parent_id\":\"\"},\"state\":{},\"team_id\":\"on95mnb5h7r73n373brm6eddrr\"}"
//            let data = message.dataUsingEncoding(NSUTF8StringEncoding)
//            self.socket.writeData(data!)
            let socketNotification = SocketNotification(channelId: channel.identifier!, teamId: DataManager.sharedInstance.currentTeam!.identifier!, act: action.rawValue)
            let json = JSON(socketNotification)
            parameters.
            try! socket.writeData(json.rawData())
        }
    }
    
    private func publishLocalNotificationWithChannelIdentifier(channelIdentifier: String, userIdentifier: String, action: ChannelAction) {
        guard action != ChannelAction.Unknown else {
            return
        }
        let notificationName = ActionsNotification.notificationNameForChannelIdentifier(channelIdentifier)
        let notification = ActionsNotification(userIdentifier: userIdentifier, action: action)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: notification)
    }
}

//MARK: - State Control
extension SocketManager: StateControl {
    private func shouldConnect() -> Bool{
        return Api.sharedInstance.isSignedIn() && !self.socket.isConnected
    }
    private func shouldSendNotification() -> Bool {
        let date = NSDate()
        if (lastNotificationDate == nil) {
            self.lastNotificationDate = date
        }
        if let previousDate = self.lastNotificationDate where date.timeIntervalSinceDate(previousDate) > Constants.Socket.TimeIntervalBetweenNotifications {
            self.lastNotificationDate = date
            return true
        }
//        return false
        return true
    }
}

//MARK: - Validation
extension SocketManager: Validation {
    private func postExistsWithIdentifier(identifier: String, pendingIdentifier: String) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "%K == %@ || %K == %@", PostAttributes.identifier.rawValue, identifier, PostAttributes.pendingId.rawValue, pendingIdentifier)
        return realm.objects(Post).filter(predicate).first != nil
    }
}
