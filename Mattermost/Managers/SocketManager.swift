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
    func sendNotificationAboutAction(_ action: ChannelAction, channel: Channel)
    func setNeedsConnect()
    func disconnect()
}

@objc final class SocketManager: NSObject {
    static var sharedInstance = SocketManager()
    //refactor seqNumber
    static var seqNumber = 1
    fileprivate var lastNotificationDate: Date?
    fileprivate lazy var socket: WebSocket = {
        let webSocket = WebSocket(url: Api.sharedInstance.baseURL().appendingPathComponent(UserPathPatternsContainer.socketPathPattern()).URLWithScheme(.WSS)!)
        webSocket.delegate = self
        webSocket.setCookie(UserStatusManager.sharedInstance.cookie())
        return webSocket
    }()
    
    static func resetSocket() {
        self.sharedInstance = SocketManager()
    }
}

private protocol Notifications: class {
    func publishBackendNotificationAboutAction(_ action: ChannelAction, channelId:String)
    func publishLocalNotificationWithChannelIdentifier(_ channelIdentifier: String, userIdentifier: String, action: String?)
    func publishBackendNotificationFetchStatuses()
    func publishLocalNotificationStatusSetup(_ statuses:[String:String])
}

private protocol StateControl: class {
    func shouldConnect() -> Bool
    func shouldSendNotification() -> Bool
}

private protocol Validation: class {
    func postExistsWithIdentifier(_ identifier: String, pendingIdentifier: String) -> Bool
}

private protocol MessageHandling: class {
    func handleIncomingMessage(_ text: String)
}


// MARK: - WebSocket Delegate
extension SocketManager: WebSocketDelegate{
    func websocketDidConnect(socket: WebSocket) {
        NSLog("Socket did connect")
//        publishBackendNotificationFetchStatuses()
    }
    func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {}
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
    func sendNotificationAboutAction(_ action: ChannelAction, channel: Channel) {
        self.publishBackendNotificationAboutAction(action, channelId: channel.identifier!)
    }
    func setNeedsConnect() {
//        setupSocket()
        if shouldConnect() {
            self.socket.connect()
        }
    }
    func disconnect() {
        socket.disconnect(forceTimeout: 0)
    }
    
    func setupSocket() {
        
    }
}


//MARK: - Incoming Messages Handling
extension SocketManager: MessageHandling {
    fileprivate func handleIncomingMessage(_ text: String) {
        let dictionary = text.toDictionary()!
//        print(dictionary)
        //let userId = dictionary[NotificationKeys.UserIdentifier] as? String
        //let channelId = dictionary[NotificationKeys.ChannelIdentifier] as? String
        let userId = dictionary[NotificationKeys.Data]?[NotificationKeys.UserIdentifier] as? String
        let channelId = dictionary[NotificationKeys.Broadcast]?[NotificationKeys.ChannelIdentifier] as? String
        switch(SocketNotificationUtils.typeForNotification(dictionary)) {
            case .error: break
//                print("ERROR "+text)
            case .default:
                break
            case .receivingPost:
//                print("New post")
                let channelName = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.ChannelName] as! String
                let channelType = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.ChannelType] as! String
                let senderName = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.SenderName] as! String
                let postString = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.Post] as! String
                let post = SocketNotificationUtils.postFromDictionary(postString.toDictionary()!)
                handleReceivingNewPost(channelId!,channelName: channelName,channelType: channelType,senderName: senderName,post: post)
            case .receivingUpdatedPost:
//                print("Updated post")
                let postString = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.Post] as! String
                let post = SocketNotificationUtils.postFromDictionary(postString.toDictionary()!)
                handleReceivingUpdatedPost(post)
            case .receivingDeletedPost:
//                print("Deleted post")
                let postString = dictionary[NotificationKeys.Data]?[NotificationKeys.DataKeys.Post] as! String
                let post = SocketNotificationUtils.postFromDictionary(postString.toDictionary()!)
                handleReceivingDeletedPost(post)
            case .receivingStatus:
                guard let status = dictionary[NotificationKeys.Data]?[NotificationKeys.Status] as? String else { return }
                publishLocalNotificationStatusChanged(userId!, status: status)
            case .receivingStatuses:
                guard let statuses = dictionary[NotificationKeys.Data] as? [String:String] else { return }
                publishLocalNotificationStatusSetup(statuses)
            case .receivingTyping:
                publishLocalNotificationWithChannelIdentifier(channelId!, userIdentifier: userId!, action: Event.Typing.rawValue)
            case .joinedUser:
                publishLocalNotificationJoin(userIdentifier: userId!, to: channelId!)
            default: break
//                print("UNKNW: "+text)
                //reply with event:"hello"
//                publishBackendNotificationFetchStatuses()
        }
    }
}


//MARK: - Notifications
extension SocketManager: Notifications {
    func publishBackendNotificationAboutAction(_ action: ChannelAction, channelId:String) {
            socket.write(data:SocketNotificationUtils.dataForActionRequest(action, seq: SocketManager.seqNumber, channelId: channelId))
            // ++ is deprecated. refactor later seq number
            SocketManager.seqNumber = SocketManager.seqNumber + 1
    }
    
    func publishBackendNotificationAboutUserAction(_ action: ChannelAction, channelId:String) {
        if shouldSendNotification() {
            publishBackendNotificationAboutAction(action, channelId: channelId)
        }
    }
        
    func publishBackendNotificationFetchStatuses() {
        publishBackendNotificationAboutAction(ChannelAction.Statuses, channelId: "null channel id")
    }
    
    func handleReceivingNewPost(_ channelId:String,channelName:String,channelType:String,senderName:String,post:Post) {
        // if user is not author
        if !postExistsWithIdentifier(post.identifier!, pendingIdentifier: post.pendingId!) {
            RealmUtils.save(post)
            
            for file in post.files {
                Api.sharedInstance.getInfo(fileId: file.identifier!)
            }
            
            try! RealmUtils.realmForCurrentThread().write({
                if post.channel != nil {
                    post.channel.lastPostDate = post.createdAt
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
            })
            
            guard let channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId) else {
                return
            }
            Api.sharedInstance.getChannel(channel: channel, completion: { error in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
            })
            
//            Api.sharedInstance.getChannelMembers(completion: { error in
//                guard error == nil else { return }
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
//            })
        }
    }
    
    func handleReceivingUpdatedPost(_ updatedPost:Post) {
        if postExistsWithIdentifier(updatedPost.identifier!, pendingIdentifier: updatedPost.pendingId!) {
            guard let existedPost = RealmUtils.realmForCurrentThread().objects(Post.self).filter("%K == %@", PostAttributes.identifier.rawValue, updatedPost.identifier!).first else { return }
            updatedPost.localIdentifier = existedPost.localIdentifier
        }
        RealmUtils.save(updatedPost)
    }
    
    func handleReceivingDeletedPost(_ deletedPost:Post) {
        // if user is not author
        let day = deletedPost.day
        if postExistsWithIdentifier(deletedPost.identifier!, pendingIdentifier: deletedPost.pendingId!) {
            let post = RealmUtils.realmForCurrentThread().objects(Post.self).filter("%K == %@", "identifier", deletedPost.identifier!).first
            guard post != nil else { return }
            RealmUtils.deleteObject(post!)
            if day?.posts.count == 0 {
                RealmUtils.deleteObject(day!)
            }
        }
    }
    
    fileprivate func publishLocalNotificationWithChannelIdentifier(_ channelIdentifier: String, userIdentifier: String, action: String?) {
        guard action != nil else {
            return
        }
        let channelEvent = Event(rawValue: action!)
        let notificationName = ActionsNotification.notificationNameForChannelIdentifier(channelIdentifier)
        let notification = ActionsNotification(userIdentifier: userIdentifier, event: channelEvent)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName!), object: notification)
    }
    fileprivate func publishLocalNotificationStatusChanged(_ userIdentifier: String, status: String) {
        let notification = StatusChangingSocketNotification(userIdentifier: userIdentifier, status: status)
        let notificationName = StatusChangingSocketNotification.notificationName()
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: notification)
    }
    fileprivate func publishLocalNotificationStatusSetup(_ statuses:[String:String]) {
        let notificationName = Constants.NotificationsNames.StatusesSocketNotification
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: statuses)
    }
    fileprivate func publishLocalNotificationJoin(userIdentifier: String, to channelIdentifier: String) {
        
        let user = RealmUtils.realmForCurrentThread().objects(User.self).filter("%K == %@", "identifier", userIdentifier).first
        var channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter("%K == %@", "identifier", channelIdentifier).first
        
        //user joined to team -> loadUsers
        if user == nil {
            //request for user information
        }
        
        if channel == nil {
            //request for chanel information (temp load all channels)
            Api.sharedInstance.loadChannels(with: { (error) in
                guard error == nil else { return }
                channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter("%K == %@", "identifier", channelIdentifier).first
                if channel != nil {
                    self.handleUserJoined(user: user!, channel: channel!)
                }
            })
        } else {
//FIXME: Crash here, when other user has joined to current channel
            guard let usr = user, let chnl = channel else {
                print("FIX ME PLS")
                return
            }
            
            handleUserJoined(user: usr, channel: chnl)
        }
    }
    
    fileprivate func handleUserJoined(user: User, channel: Channel) {
        try! RealmUtils.realmForCurrentThread().write {
            channel.members.append(user)
        }
        
        //If joined current user -> reload left menu
        let notificationName = Constants.NotificationsNames.UserJoinNotification
        try! RealmUtils.realmForCurrentThread().write {
            channel.currentUserInChannel = true
        }
        if user.identifier == Preferences.sharedInstance.currentUserId {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: channel)
        }
    }
}


//MARK: - State Control
extension SocketManager: StateControl {
    fileprivate func shouldConnect() -> Bool{
        return UserStatusManager.sharedInstance.isSignedIn() && !self.socket.isConnected
    }
    fileprivate func shouldSendNotification() -> Bool {
        let date = Date()
        if (lastNotificationDate == nil) {
            self.lastNotificationDate = date
        }
        if let previousDate = self.lastNotificationDate , date.timeIntervalSince(previousDate) < Constants.Socket.TimeIntervalBetweenNotifications {
            self.lastNotificationDate = date
            return true
        }
        return false
    }
}


//MARK: - Validation
extension SocketManager: Validation {
    fileprivate func postExistsWithIdentifier(_ identifier: String, pendingIdentifier: String) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "%K == %@ || %K == %@", PostAttributes.identifier.rawValue, identifier, PostAttributes.pendingId.rawValue, pendingIdentifier)
        return realm.objects(Post.self).filter(predicate).first != nil
    }
}
