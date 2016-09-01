//
//  Day.swift
//  Mattermost
//
//  Created by Maxim Gubin on 12/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

enum DayAttributes: String {
    case key = "key"
    case channelId = "channelId"
    case text = "text"
    case date = "date"
}

enum DayRelationships: String {
    case posts = "posts"
}

final class Day: RealmObject {
    dynamic var key: String?
    dynamic var channelId: String?
    dynamic var text: String?
    dynamic var date: NSDate? {
        didSet {
            self.text = NSDateFormatter.sharedConversionSectionsDateFormatter.stringFromDate(self.date!)
        }
    }
    let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.day.rawValue)

    
    override class func primaryKey() -> String {
        return DayAttributes.key.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [DayAttributes.channelId.rawValue, DayAttributes.date.rawValue]
    }
}