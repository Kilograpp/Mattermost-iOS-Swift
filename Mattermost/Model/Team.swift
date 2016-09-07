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

//private protocol ResponseMappings: class {
//    static func mapping() -> RKObjectMapping
//    static func initialLoadConfigMapping() -> RKObjectMapping
//}

public enum TeamAttributes: String {
    case identifier = "identifier"
    case displayName = "displayName"
    case name = "name"
}


// MARK: - Mapping
//extension Team: ResponseMappings {
//    override static func mapping() -> RKObjectMapping {
//        let entityMapping = super.mapping()
//        entityMapping.addAttributeMappingsFromDictionary(["display_name" : TeamAttributes.displayName.rawValue])
//        entityMapping.addAttributeMappingsFromArray([TeamAttributes.name.rawValue])
//        return entityMapping
//    }
//    static func initialLoadConfigMapping() -> RKObjectMapping {
//        let entityMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
//        entityMapping.addAttributeMappingsFromDictionary(["SiteName" : PreferencesAttributes.siteName.rawValue])
//        return entityMapping
//    }
//}


