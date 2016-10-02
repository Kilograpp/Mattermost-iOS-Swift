//
//  SocketNotificationsUtils.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 19.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct NotificationKeys {
    // General
    static let ChannelIdentifier = "channel_id"
    static let TeamIdentifier = "team_id"
    static let UserIdentifier = "user_id"
    static let Identifier = "id"
    static let PendingPostIdentifier = "pending_post_id"
    // Sending
    static let Action = "action"
    static let Seq = "seq"
    // Receiving
    static let Event = "event"
    // Reply after sending
    static let Status = "status"
    static let SeqReply = "seq_reply"
    // Data
    static let Data = "data"
    struct DataKeys {
        static let ChannelName = "channel_display_name"
        static let ChannelType = "channel_type"
        static let SenderName = "sender_name"
        static let Post = "post"
        static let ParentIdentifier = "parent_id"
        static let UserStatus = "status"
        struct PostKeys {
            static let Create_at = "create_at"
            static let Update_at = "update_at"
            static let Delete_at = "delete_at"
            static let RootIdentifier = "root_id"
            static let ParentIdentifier = "parent_id"
            static let Message = "message"
            static let Files = "filenames"
            //Also : channelId, userId, pendingPostId, Id
            
            //Undefined in Post class as RealmObject
            static let Props = "props"
            static let Type = "type"
            static let Hashtags = "hashtags"
            
        }
    }
}

enum NotificationType: Int {
    case Error = -1             //error
    case Default = 0            //OK
    case ReceivingPost = 1      //receiving new post
    case ReceivingUpdatedPost   //receiving new post
    case ReceivingDeletedPost
    case ReceivingTyping        //receiving action
    case ReceivingStatus    //receiving user status change
    case ReceivingStatuses  //receiving all user statuses
    case Unknown
}

enum Event: String {
    case Typing = "typing"
    case ChannelView = "channel_viewed"
    case Posted = "posted"
    case Deleted = "post_deleted"
    case Updated = "post_edited"
    case StatusChanged = "status_change"
    case UserAdded = "user_added"
    case Unknown
}

enum ChannelAction: String {
    case Typing = "user_typing"
    case Statuses = "get_statuses"
    case Unknown
}


final class SocketNotificationUtils {
    
    static func dataForActionRequest(action:ChannelAction, seq:Int, channelId:String?) -> NSData {
        var parameters = [String: JSON]()
        parameters[NotificationKeys.Action] = JSON(stringLiteral: action.rawValue)
        parameters[NotificationKeys.Seq] = JSON(integerLiteral: seq)
        switch action {
        case .Statuses:
            break
        case .Typing:
            parameters[NotificationKeys.Data] = JSON(["parent_id" : "" , "channel_id" : channelId!])
        default:
            return NSData()
        }
        let json = JSON(parameters)
        return try! json.rawData()
    }
    
    //todo: files supporting (NotificationKeys.DataKeys.PostKeys.Files)
    static func postFromDictionary(dictionary:[String:AnyObject]) -> Post {
        var post = Post()
        // ? pending post id
        post.message = dictionary[NotificationKeys.DataKeys.PostKeys.Message] as? String
        post.identifier = dictionary[NotificationKeys.Identifier] as? String
        post.authorId = dictionary[NotificationKeys.UserIdentifier] as? String
        post.channelId = dictionary[NotificationKeys.ChannelIdentifier] as? String
 
        post.createdAt = NSDate(timeIntervalSince1970: dictionary[NotificationKeys.DataKeys.PostKeys.Create_at] as! NSTimeInterval/1000.0)
        post.updatedAt = NSDate(timeIntervalSince1970: dictionary[NotificationKeys.DataKeys.PostKeys.Update_at] as! NSTimeInterval/1000.0)
        post.deletedAt = NSDate(timeIntervalSince1970: dictionary[NotificationKeys.DataKeys.PostKeys.Delete_at] as! NSTimeInterval/1000.0)

        post.computeMissingFields()
        return post
    }
    
    static func typeForNotification(dictionary:[String:AnyObject]) -> NotificationType {
        guard let event = dictionary[NotificationKeys.Event] as? String else {
            guard let reply = dictionary[NotificationKeys.Status] as? String else {
                return .Unknown
            }
            if dictionary[NotificationKeys.Data] == nil {
                if reply != "OK" {
                    return .Error
                }
                return .Default
            } else {
                return .ReceivingStatuses
            }
        }
        switch (event) {
        case Event.Typing.rawValue:
            return .ReceivingTyping
        case Event.Posted.rawValue:
            return .ReceivingPost
        case Event.Deleted.rawValue:
            return .ReceivingDeletedPost
        case Event.Updated.rawValue:
            return .ReceivingUpdatedPost
        case Event.StatusChanged.rawValue:
            return .ReceivingStatus
        default:
            return .Unknown
        }
    }
}

class SocketNotification {
    let userId: String
    var channelId: String?
    var teamId: String?
    
    init(userIdentifier: String) {
        self.userId = userIdentifier
    }
    
    
}

class StatusChangingSocketNotification: SocketNotification {
    let status: String!
    
    init(userIdentifier: String, status: String) {
        self.status = status
        
        super.init(userIdentifier: userIdentifier)
    }
    
    static func notificationName() -> String {
        return "UserStatusUpdatingNotification"
    }
}

