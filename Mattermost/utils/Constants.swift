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
        static let UserLogoutNotificationName      = "LogoutNotification"
        static let StatusesSocketNotification      = "StatusesSocketNotification"
        static let UserJoinNotification            = "UserJoinNotification"
        static let UserTeamSelectNotification      = "UserTeamSelectNotification"
        static let ChatLoadingStartNotification    = "ChatLoadingStartNotification"
        static let ChatLoadingStopNotification     = "ChatLoadingStopNotification"
        static let ReloadLeftMenuNotification      = "ReloadLeftMenuNotification"
        static let ReloadRightMenuNotification     = "ReloadRightMenuNotification"
        static let ReloadChatNotification          = "ReloadChatNotification"
        static let DocumentInteractionNotification = "DocumentInteractionNotification"
        static let ReloadFileSizeNotification      = "ReloadFileSizeNotification"
        static let DidReceiveRemoteNotification    = "DidReceiveRemoteNotification"
        static let FileImageDidTapNotification     = "FileImageDidTapNotification"
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
                                             (title: "Nickname", icon: "profile_nick_icon"), (title: "Profile photo", icon: "profile_photo_icon") ]
        static let SecondSecionDataSource = [ (title: "Email", icon: "profile_email_icon"), (title: "Change password", icon: "profile_pass_icon"),
                                              (title: "Notification", icon: "profile_notification_icon")]
    }
    
    struct RightMenuRows {
        static let SwitchTeam: Int       = 0
        static let Settings: Int         = 1
        static let InviteNewMembers: Int = 2
        static let About: Int            = 3
        static let Logout: Int           = 4
    }
    
    struct NotifyProps {
        static let Send = [ (state: "all", description: "For all activity"), (state: "mention", description: "For mentions and direct messages"), (state: "none", description: "Never") ]
        struct DesktopPush {
            static let Duration = [ (state: "3", description: "3 seconds"), (state: "5", description: "5 seconds"), (state: "10", description: "10 seconds"), (state: "0", description: "Unlimited") ]
        }
        struct MobilePush {
            static let Trigger = [ (state: "online", description: "Online, away or offline"), (state: "away", description: "Away or offline"), (state: "offline", description: "Offline") ]
        }
        struct Words {
            static let ChannelWide = "\"@channel\", \"@all\""
            static let None = "No words configured"
        }
        struct Reply {
            static let Trigger = [ (state: "any", description: "Trigger notifications on messages in reply threads that I start or participate in"), (state: "root", description: "Trigger notifications on messages in threads that I start"), (state: "never", description: "Do not trigger notifications on messages in reply threads unless I'm mentioned") ]
        }
    }
    
    struct UserFieldType {
        static let FullName: Int = 0
        static let UserName: Int = 1
        static let NickName: Int = 2
        static let Email: Int    = 3
        static let Password: Int = 4
    }
        
    struct CommonKeyPaths {
        static let Teams = "teams"
    }
    
    struct CommonStrings {
        static let True = "true"
        static let False = "false"
    }
}
