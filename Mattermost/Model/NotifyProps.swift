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
    dynamic var channel: Bool = false
    dynamic var comments: String?
    dynamic var desktop: String?
    dynamic var desktopDuration: Int = 0
    dynamic var desktop_sound: Bool = false
    dynamic var email: Bool = false
    dynamic var firstName: Bool = false
    dynamic var mentionKeys: String?
    dynamic var push: String?
    dynamic var pushStatus: String?
    
    
//    let user = LinkingObjects(fromType: User.self, property: UserRelationships.notifyProps.rawValue)
    
 /*   override class func primaryKey() -> String {
        return NotifyPropsAttributes.key.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [NotifyPropsAttributes.channelId.rawValue, DayAttributes.date.rawValue]
    }*/
}

enum NotifyPropsAttributes: String {
    case channel = "channel"
    case comments = "comments"
    case desktop = "desktop"
    case desktopDuration = "desktopDuration"
    case desktopSound = "desktopSound"
    case email = "email"
    case firstName = "firstName"
    case mentionKeys = "mentionKeys"
    case push = "push"
    case pushStatus = "pushStatus"
}
