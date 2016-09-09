//
//  Team.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class Team: RealmObject {
    dynamic var identifier: String?
    dynamic var displayName: String?
    dynamic var name: String?
    
    override static func indexedProperties() -> [String] {
        return [TeamAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return TeamAttributes.identifier.rawValue
    }
}

public enum TeamAttributes: String {
    case identifier = "identifier"
    case displayName = "displayName"
    case name = "name"
}

