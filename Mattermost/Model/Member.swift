//
//  Member.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 05.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class Member: RealmObject {
    
    dynamic var channelId: String?
    dynamic var userId: String?
    dynamic var roles: String?
    dynamic var lastViewedAt: Date?
    dynamic var lastUpdateAt: Date?
    dynamic var key: String!
    dynamic var msgCount: Int = 0
    dynamic var mentionCount: Int = 0
    
    override static func indexedProperties() -> [String] {
        return [MemberAttributes.key.rawValue]
    }
    override static func primaryKey() -> String? {
        return MemberAttributes.key.rawValue
    }
    func computeKey() {
        self.key = "\(userId)__\(channelId)"
    }
}

enum MemberAttributes: String {
    case userId = "user_id"
    case roles = "roles"
    case lastViewedAt = "last_viewed_at"
    case lastUpdateAt = "last_update_at"
    case key = "key"
    case msgCount = "msg_count"
    case mentionCount = "mention_count"
}

