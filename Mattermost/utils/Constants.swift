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
        static let UserJoinNotification = "UserJoinNotification"
        static let UserTeamSelectNotification = "UserTeamSelectNotification"
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
        static let PrivateTypeChannel = "P"
        static let DirectTypeChannel = "D"
    }
    
    struct EmojiArrays {
        static let apple: Array = [ "😠", "☺️", "😰", "😖", "😢", "😞", "😥", "😨", "😳", "😁", "😀", "😍", "😂", "😗", "😚", "😘", "😙", "😆", "😔",
                                    "😣", "😡", "😡", "😊", "😌", "😆", "😱", "😪", "😄", "😃", "😭", "😛", "😜", "😝", "😓", "😅", "😩", "😤", "😒",
                                    "😫", "😉" ]
        static let mattermost: Array = [ "angry", "blush", "cold_sweat", "confounded", "cry", "disappointed", "disappointed_relieved", "fearful", "flushed",
                                         "grin", "grinning", "heart_eyes", "joy", "kissing", "kissing_closed_eyes", "kissing_heart", "kissing_smiling_eyes",
                                         "laughing", "pensive", "persevere", "pout", "rage", "relaxed", "relieved", "satisfied", "scream", "sleepy", "smile",
                                         "smiley", "sob", "stuck_out_tongue", "stuck_out_tongue_closed_eyes", "stuck_out_tongue_winking_eye", "sweat",
                                         "sweat_smile", "tired_face", "triumph", "unamused", "weary", "wink" ]
    }
    
    struct Profile {
        static let SectionsCount = 2
        static let FirsSectionDataSource = [ (title: "Name", icon: "profile_name_icon"), (title: "Username", icon: "profile_usename_icon"),
                                             (title: "Nickname", icon: "profile_nick_icon"), ]
        static let SecondSecionDataSource = [ (title: "Email", icon: "profile_email_icon") ]
    }
    
    struct RightMenuRows {
        static let SwitchTeam: Int       = 0
        static let Files: Int            = 1
        static let Settings: Int         = 2
        static let InviteNewMembers: Int = 3
        static let Help: Int             = 4
        static let Report: Int           = 5
        static let About: Int            = 6
        static let Logout: Int           = 7
    }

}
