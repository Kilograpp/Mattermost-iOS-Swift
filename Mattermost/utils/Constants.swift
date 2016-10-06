//
//  Constants.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct Constants {
    struct Api {
        static let Route = "api/v3"
    }
    struct Http {
        struct Headers {
            static let ContentType    = "Content-Type"
            static let RequestedWith  = "X-Requested-With"
            static let AcceptLanguage = "Accept-Language"
            static let Cookie         = "Cookie"
        }
    }
    struct Realm {
        static let SystemUserIdentifier = "SystemUserIdentifier"
    }
    struct Common {
        static let RestKitPrefix              = "RK"
        static let MattermostCookieName       = "MMAUTHTOKEN"
        static let UserDefaultsPreferencesKey = "com.kilograpp.mattermost.preferences"
    }
    struct StringAttributes {
        static let Mention = "MattermostMention"
        static let HashTag = "MattermostHashTag"
        static let Phone   = "MattermostPhone"
        static let Email   = "MattermostEmail"
    }
    struct Socket {
        static let TimeIntervalBetweenNotifications: Double = 5.0
    }
    
    struct NotificationsNames {
        static let UserLogoutNotificationName = "LogoutNotification"
        static let StatusesSocketNotification = "StatusesSocketNotification"
    }
    
    struct UI {
        static let FeedCellMessageLabelPaddings: CGFloat = 61
        static let FeedCellIndicatorPadding: CGFloat     = 22
        static let PostStatusViewSize: CGFloat           = 34
        static let ShortPaddingSize: CGFloat             = 5
        static let MiddlePaddingSize: CGFloat            = 8
        static let StandardPaddingSize: CGFloat          = 16
        static let LongPaddingSize: CGFloat              = 10
        static let DoublePaddingSize: CGFloat            = 20
        static let MessagePaddingSize: CGFloat           = 53
    }
    
    struct PostActionType {
        static let SendNew     = "sendNew"
        static let SendReply   = "sendReply"
        static let SendUpdate  = "sendUpdate"
        static let DeleteOwn   = "deleteOwn"
    }
    
    struct ChannelType {
        static let PublicTypeChannel  = "O"
        static let PrivateTypeChannel = "D"
    }
}
