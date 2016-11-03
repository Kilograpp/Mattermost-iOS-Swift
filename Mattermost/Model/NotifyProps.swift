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
    dynamic var key: String!
    
    override static func indexedProperties() -> [String] {
        return [MemberAttributes.key.rawValue]
    }
    override static func primaryKey() -> String? {
        return MemberAttributes.key.rawValue
    }
    
    func computeKey() {
        self.key = "\(userId)__notifyProps"
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
