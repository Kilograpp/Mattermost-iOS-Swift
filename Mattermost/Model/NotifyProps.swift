//
//  NotifyProps.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

protocol Desktop {
    func completeDesctop() -> String
}

protocol Email {
    func completeEmail() -> String
}

protocol MobilePush {
    func completeMobilePush() -> String
}

protocol TriggerWords {
    func isSensitiveFirstName() -> Bool
    func isNonCaseSensitiveUsername() -> Bool
    func isUsernameMentioned() -> Bool
    func isChannelWide() -> Bool
    func otherNonCaseSensitive() -> String
    func completeTriggerWords() -> String
}

protocol Reply {
    func completeReply() -> String
}


final class NotifyProps: RealmObject {
    dynamic var channel: String? = "true"
    dynamic var comments: String? = "never"
    dynamic var desktop: String? = "all"
    dynamic var desktopDuration: String? = "3"
    dynamic var desktopSound: String? = "true"
    dynamic var email: String? = "true"
    dynamic var firstName: String? = "true"
    dynamic var mentionKeys: String? = ""
    dynamic var push: String? = "all"
    dynamic var pushStatus: String? = "online"
    dynamic var userId: String?
    dynamic var key: String! = "__notifyProps"
    dynamic var hasUpdated: Bool = false
    
    override static func indexedProperties() -> [String] {
        return [NotifyPropsAttributes.key.rawValue]
    }
    override static func primaryKey() -> String? {
        return NotifyPropsAttributes.key.rawValue
    }
    
    func computeKey() {
        self.key = "\(userId!)__notifyProps"
    }
}

enum NotifyPropsAttributes: String {
    case channel         = "channel"
    case comments        = "comments"
    case desktop         = "desktop"
    case desktopDuration = "desktopDuration"
    case desktopSound    = "desktopSound"
    case email           = "email"
    case firstName       = "firstName"
    case mentionKeys     = "mentionKeys"
    case push            = "push"
    case pushStatus      = "pushStatus"
    case userId          = "userId"
    case key             = "key"
}


//MARK: Desktop
extension NotifyProps: Desktop {
    func completeDesctop() -> String {
        return "For all activity, with sound, shown for 5 sec"
    }
}


//MARK: Email
extension NotifyProps: Email {
    func completeEmail() -> String {
        return "Immediately"
    }
}


//MARK: MobilePush
extension NotifyProps: MobilePush {
    func completeMobilePush() -> String{
        print((self.push)!)
        let sendIndex = Constants.NotifyProps.MobilePush.Send.index { return $0.state == (self.push)! }!
        print((self.pushStatus)!)
        let triggerIndex = Constants.NotifyProps.MobilePush.Trigger.index { return $0.state == (self.pushStatus)! }!
        let send = Constants.NotifyProps.MobilePush.Send[sendIndex].description
        let trigger = Constants.NotifyProps.MobilePush.Trigger[triggerIndex].description
        return send + " when " + trigger
    }
}


//MARK: TriggerWords
extension NotifyProps: TriggerWords {
    func isSensitiveFirstName() -> Bool {
        return self.firstName == "true"
    }
    
    func isNonCaseSensitiveUsername() -> Bool {
        var mention = self.mentionKeys
        let username = DataManager.sharedInstance.currentUser?.username
        mention = mention?.replacingOccurrences(of: ("@" + username!), with: "")
        
        return (mention?.contains(username!))!
    }
    
    func isUsernameMentioned() -> Bool {
        let mention = self.mentionKeys
        let username = "@" + (DataManager.sharedInstance.currentUser?.username)!
        
        return (mention?.contains(username))!
    }
    
    func isChannelWide() -> Bool {
        return self.channel == "true"
    }
    
    func otherNonCaseSensitive() -> String {
        var mention = self.mentionKeys
        let username = DataManager.sharedInstance.currentUser?.username
        mention = mention?.replacingOccurrences(of: ("@" + username!), with: "")
        mention = mention?.replacingOccurrences(of: (username!), with: "")
        mention = mention?.replacingOccurrences(of: ",,", with: ",")
        if (mention?.hasPrefix(","))! {
            mention?.remove(at: (mention?.startIndex)!)
        }
        
        if (mention?.hasSuffix(","))! {
            mention?.remove(at: (mention?.endIndex)!)
        }
        
        return mention!
    }
    
    func completeTriggerWords() -> String {
        let user = DataManager.sharedInstance.currentUser
        var words = self.isSensitiveFirstName() ? StringUtils.quotedString(user?.firstName) : ""
        if self.isNonCaseSensitiveUsername() {
            words += StringUtils.commaTailedString(words)
            words += StringUtils.quotedString(user?.username!)
        }
        if self.isUsernameMentioned() {
            words += StringUtils.commaTailedString(words)
            words += StringUtils.quotedString("@" + (user?.username!)!)
        }
        if self.isChannelWide() {
            words += StringUtils.commaTailedString(words)
            words += Constants.NotifyProps.Words.ChannelWide
        }
        let otherWords = self.otherNonCaseSensitive()
        if (otherWords.characters.count > 0) {
            words += StringUtils.commaTailedString(words)
            words += otherWords
        }
        
        return (words.characters.count > 0) ? words : Constants.NotifyProps.Words.None
    }
}


//MARK: Reply
extension NotifyProps: Reply {
    func completeReply() -> String {
        return "Do not trigger notifications on message"
    }
}
