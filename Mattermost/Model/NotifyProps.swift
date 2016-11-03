//
//  NotifyProps.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class NotifyProps: RealmObject {
    dynamic var channel: String?
    dynamic var comments: String?
    dynamic var desktop: String?
    dynamic var desktopDuration: String?
    dynamic var desktopSound: String?
    dynamic var email: String?
    dynamic var firstName: String?
    dynamic var mentionKeys: String?
    dynamic var push: String?
    dynamic var pushStatus: String?
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

extension NotifyProps {
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
}

