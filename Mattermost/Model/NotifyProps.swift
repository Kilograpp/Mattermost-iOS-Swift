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
    dynamic var desktop_duration: Int = 0
    dynamic var desktop_sound: Bool = false
    dynamic var email: Bool = false
    dynamic var first_name: Bool = false
    dynamic var mention_keys: String?
    dynamic var push: String?
    dynamic var push_status: String?
    
    
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
    case desktop_duration = "desktop_duration"
    case desktop_sound = "desktop_sound"
    case email = "email"
    case first_name = "first_name"
    case mention_keys = "mention_keys"
    case push = "push"
    case push_status = "push_status"
}
