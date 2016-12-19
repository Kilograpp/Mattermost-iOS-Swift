//
//  Preference.swift
//  Mattermost
//
//  Created by TaHyKu on 31.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class Preference: RealmObject {
    dynamic var userId: String?
    dynamic var category: String?
    dynamic var name: String?
    dynamic var value: String?
    dynamic var key: String!
    
    override class func primaryKey() -> String {
        return  PreferenceAttributes.key.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [PreferenceAttributes.key.rawValue]
    }
    
    func computeKey() {
        self.key = "\(userId)__\(category)__\(name)"
    }
    
    static func preferedUsersList() -> Results<Preference> {
        let realm = RealmUtils.realmForCurrentThread()
        
        let predicate = NSPredicate(format: "category == \"direct_channel_show\" AND value == \"true\"")
        return realm.objects(Preference.self).filter(predicate)
    }
}

public enum PreferenceAttributes: String {
    case userId   = "userId"
    case category = "category"
    case name     = "name"
    case value    = "value"
    case key      = "key"
}
