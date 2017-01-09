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
    func completeDesktop() -> String
    func sendDesktopState() -> String
    func isDesktopSoundOn() -> Bool
    func desktopDurationState() -> String
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
    dynamic var key: String?
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
    func completeDesktop() -> String {
        let desktop = sendDesktopState()
        let sound = isDesktopSoundOn() ? "with" : "without" + " sound"
        let duration = "shown " + desktopDurationState()
        
        return desktop + ", " + sound + ", " + duration
    }
    
    func sendDesktopState() -> String {
        let desktopIndex = Constants.NotifyProps.Send.index{ return $0.state == (self.desktop)! }!
        let desktopDescription = Constants.NotifyProps.Send[desktopIndex].description
        return desktopDescription
    }
    
    func isDesktopSoundOn() -> Bool {
        return (self.desktopSound == /*"true"*/Constants.CommonStrings.True)
    }
    
    func desktopDurationState() -> String {
        let durationIndex = Constants.NotifyProps.DesktopPush.Duration.index { return $0.state == (self.desktopDuration)! }!
        let duration = Constants.NotifyProps.DesktopPush.Duration[durationIndex].description
        return duration
    }
}


//MARK: Email
extension NotifyProps: Email {
    func completeEmail() -> String {
        return (self.email == /*"true"*/Constants.CommonStrings.True) ? "Immediately" : "Never"
    }
}


//MARK: MobilePush
extension NotifyProps: MobilePush {
    func completeMobilePush() -> String{
//        print((self.push)!)
        let sendIndex = Constants.NotifyProps.Send.index { return $0.state == (self.push)! }!
//        print((self.pushStatus)!)
        let triggerIndex = Constants.NotifyProps.MobilePush.Trigger.index { return $0.state == (self.pushStatus)! }!
        let send = Constants.NotifyProps.Send[sendIndex].description
        let trigger = Constants.NotifyProps.MobilePush.Trigger[triggerIndex].description
        return send + " when " + trigger
    }
}


//MARK: TriggerWords
extension NotifyProps: TriggerWords {
    func isSensitiveFirstName() -> Bool {
        return (self.firstName == Constants.CommonStrings.True)
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
        return self.channel == Constants.CommonStrings.True//"true"
    }
    
    func otherNonCaseSensitive() -> String {
        var mention = self.mentionKeys?.replacingOccurrences(of: " ", with: "")
        let username = DataManager.sharedInstance.currentUser?.username
        
        var words = mention?.components(separatedBy: ",")
        words?.removeObject("@" + username!)
        words?.removeObject(username!)
        mention = (words?.joined(separator: ","))!
        
        return mention!
    }
    
    func completeTriggerWords() -> String {
        let user = DataManager.sharedInstance.currentUser
//        print(self.isSensitiveFirstName())
        var words = self.isSensitiveFirstName() ? StringUtils.quotedString(user?.firstName) : ""
        if self.isNonCaseSensitiveUsername() {
            words = StringUtils.commaTailedString(words)
            words += StringUtils.quotedString(user?.username!)
        }
        if self.isUsernameMentioned() {
            words = StringUtils.commaTailedString(words)
            words += StringUtils.quotedString("@" + (user?.username!)!)
        }
        if self.isChannelWide() {
            words = StringUtils.commaTailedString(words)
            words += Constants.NotifyProps.Words.ChannelWide
        }
        var otherWords = self.otherNonCaseSensitive()
        if (otherWords.characters.count > 0) {
            otherWords = "\"" + otherWords.replacingOccurrences(of: ",", with: "\",\"") + "\""
            words = StringUtils.commaTailedString(words)
            words += otherWords
        }
        
        return (words.characters.count > 0) ? words : Constants.NotifyProps.Words.None
    }
}


//MARK: Reply
extension NotifyProps: Reply {
    func completeReply() -> String {
        let commentsIndex = Constants.NotifyProps.Reply.Trigger.index { return $0.state == (self.comments)! }!
        let comments = Constants.NotifyProps.Reply.Trigger[commentsIndex].description
        return comments
    }
}
