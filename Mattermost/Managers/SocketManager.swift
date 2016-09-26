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
    //refactor seqNumber
    static var seqNumber = 1
    private var lastNotificationDate: NSDate?
    private lazy var socket: WebSocket = {
        let webSocket = WebSocket(url: Api.sharedInstance.baseURL().URLByAppendingPathComponent(UserPathPatternsContainer.socketPathPattern()).URLWithScheme(.WSS)!)
        webSocket.delegate = self
        webSocket.setCookie(UserStatusManager.sharedInstance.cookie())
        return webSocket
    }()
}

private protocol Notifications: class {
    func publishBackendNotificationAboutAction(action: ChannelAction, channelId:String)
    func publishLocalNotificationWithChannelIdentifier(channelIdentifier: String, userIdentifier: String, action: String?)
    func publishBackendNotificationFetchStatuses()
    func publishLocalNotificationStatusSetup(statuses:[String:String])
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
        self.publishBackendNotificationAboutAction(action, channelId: channel.identifier!)
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
        let userId = dictionary[NotificationKeys.UserIdentifier] as? String
        let channelId = dictionary[NotificationKeys.ChannelIdentifier] as? String
        switch(SocketNotificationUtils.typeForNotification(dictionary)) {
            case .Error:
                print("ERROR "+text)
            case .Default:
                print("OK "+text)
            case .ReceivingPost:
                print("New post")
            case .ReceivingStatus:
                guard let status = dictionary[NotificationKeys.Data]?[NotificationKeys.Status] as? String else { return }
                publishLocalNotificationStatusChanged(userId!, status: status)
            case .ReceivingStatuses:
                guard let statuses = dictionary[NotificationKeys.Data] as? [String:String] else { return }
                publishLocalNotificationStatusSetup(statuses)
            case .ReceivingTyping:
                publishLocalNotificationWithChannelIdentifier(channelId!, userIdentifier: userId!, action: Event.Typing.rawValue)
                print("Typing...")
            default:
                print("UNKNW: "+text)
                //reply with event:"hello"
                publishBackendNotificationFetchStatuses()
        }
//
//
//        let action     = dictionary[NotificationKeys.Action] as? String
//        let channelId  = dictionary[NotificationKeys.ChannelIdentifier] as! String
//        let postString = dictionary[NotificationKeys.Properties]?[NotificationKeys.Post] as? NSString
//
//        
//        if let postDictionary = postString?.toDictionary() {
//            let postPendingIdentifier = postDictionary[NotificationKeys.PendingPostIdentifier] as! String
//            let postIdentifier        = postDictionary[NotificationKeys.Identifier] as! String
//            
//            if !postExistsWithIdentifier(postIdentifier, pendingIdentifier: postPendingIdentifier) {
//                
//                let post = Post()
//                post.identifier = (postDictionary[NotificationKeys.Identifier] as! String)
//                post.channelId = channelId
//                
//                Api.sharedInstance.updatePost(post, completion: { (error) in
//                    self.publishLocalNotificationWithChannelIdentifier(channelId, userIdentifier: userId, action: action)
//                })
//            }
//        } else {
//            self.publishLocalNotificationWithChannelIdentifier(channelId, userIdentifier: userId, action: action)
//        }

    }
}

//MARK: - Notifications
extension SocketManager: Notifications {
    func publishBackendNotificationAboutAction(action: ChannelAction, channelId:String) {
            socket.writeData(SocketNotificationUtils.dataForActionRequest(action, seq: SocketManager.seqNumber, channelId: channelId))
            // ++ is deprecated. refactor later seq number
            SocketManager.seqNumber = SocketManager.seqNumber + 1
    }
    
    func publishBackendNotificationAboutUserAction(action: ChannelAction, channelId:String) {
        if shouldSendNotification() {
            publishBackendNotificationAboutAction(action, channelId: channelId)
        }
    }
        
    func publishBackendNotificationFetchStatuses() {
        publishBackendNotificationAboutAction(ChannelAction.Statuses, channelId: "null channel id")
    }
    
    private func publishLocalNotificationWithChannelIdentifier(channelIdentifier: String, userIdentifier: String, action: String?) {
        guard action != nil else {
            return
        }
        let channelEvent = Event(rawValue: action!)
        let notificationName = ActionsNotification.notificationNameForChannelIdentifier(channelIdentifier)
        let notification = ActionsNotification(userIdentifier: userIdentifier, event: channelEvent)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: notification)
    }
    private func publishLocalNotificationStatusChanged(userIdentifier: String, status: String) {
        let notification = StatusChangingSocketNotification(userIdentifier: userIdentifier, status: status)
        let notificationName = StatusChangingSocketNotification.notificationName()
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: notification)
    }
    private func publishLocalNotificationStatusSetup(statuses:[String:String]) {
        let notificationName = Constants.NotificationsNames.StatusesSocketNotification
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: statuses)
    }
}

//MARK: - State Control
extension SocketManager: StateControl {
    private func shouldConnect() -> Bool{
        return UserStatusManager.sharedInstance.isSignedIn() && !self.socket.isConnected
    }
    private func shouldSendNotification() -> Bool {
        let date = NSDate()
        if (lastNotificationDate == nil) {
            self.lastNotificationDate = date
        }
        if let previousDate = self.lastNotificationDate where date.timeIntervalSinceDate(previousDate) < Constants.Socket.TimeIntervalBetweenNotifications {
            self.lastNotificationDate = date
            return true
        }
        return false
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
