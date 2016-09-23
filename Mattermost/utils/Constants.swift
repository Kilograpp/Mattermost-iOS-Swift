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
            static let ContentType = "Content-Type"
            static let RequestedWith = "X-Requested-With"
            static let AcceptLanguage = "Accept-Language"
            static let Cookie = "Cookie"
        }
    }
    struct Realm {
        static let SystemUserIdentifier = "SystemUserIdentifier"
    }
    struct Common {
        static let RestKitPrefix = "RK"
        static let MattermostCookieName = "MMAUTHTOKEN"
        static let UserDefaultsPreferencesKey = "com.kilograpp.mattermost.preferences"
        static let UserLogoutNotificationName = "LOGOUT"
    }
    struct StringAttributes {
        static let Mention = "MattermostMention"
        static let HashTag = "MattermostHashTag"
        static let Phone = "MattermostPhone"
        static let Email = "MattermostEmail"
    }
    struct Socket {
        static let TimeIntervalBetweenNotifications: Double = 5.0
    }
    
    struct UI {
        static let FeedCellMessageLabelPaddings: CGFloat = 61
        static let FeedCellIndicatorPadding: CGFloat = 22
        
    }
    
//    struct UserStatus {
//        <#fields#>
//    }
    
    struct ChannelType {
        static let PublicTypeChannel = "O"
        static let PrivateTypeChannel = "D"
    }
}