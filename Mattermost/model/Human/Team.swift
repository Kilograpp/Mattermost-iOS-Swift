//
//  Team.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class Team: RealmObject {
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

private protocol PathPattern {
    static func initialLoadPathPattern() -> String
    static func teamListingsPathPattern() -> String
}

private protocol Mapping {
    static func mapping() -> RKObjectMapping
    static func initialLoadConfigMapping() -> RKObjectMapping
}

private protocol ResponseDescriptors {
    static func initalLoadResponseDescriptor() -> RKResponseDescriptor
    static func teamListingsResponseDescriptor() -> RKResponseDescriptor
    static func initalLoadConfigResponseDescriptor() -> RKResponseDescriptor
}


public enum TeamAttributes: String {
    case identifier = "identifier"
    case displayName = "displayName"
    case name = "name"
}

// MARK: - Path Pattern
extension Team: PathPattern {
    class func initialLoadPathPattern() -> String {
        return "users/initial_load"
    }
    class func teamListingsPathPattern() -> String {
        return "teams/all_team_listings"
    }
}

// MARK: - Mapping
extension Team: Mapping {
    override class func mapping() -> RKObjectMapping {
        let entityMapping = super.mapping()
        entityMapping.addAttributeMappingsFromDictionary(["display_name" : TeamAttributes.displayName.rawValue])
        entityMapping.addAttributeMappingsFromArray([TeamAttributes.name.rawValue])
        return entityMapping
    }
    class func initialLoadConfigMapping() -> RKObjectMapping {
        let entityMapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        entityMapping.addAttributeMappingsFromDictionary(["SiteName" : PreferencesAttributes.siteName.rawValue])
        return entityMapping
    }
}

// MARK: - Response Descriptors
extension Team: ResponseDescriptors {
    class func initalLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                    method: .GET,
                                    pathPattern: initialLoadPathPattern(),
                                    keyPath: "teams",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    class func teamListingsResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: emptyMapping(),
                                    method: .GET,
                                    pathPattern: teamListingsPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    class func initalLoadConfigResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: initialLoadConfigMapping(),
                                    method: .GET,
                                    pathPattern: initialLoadPathPattern(),
                                    keyPath: "client_cfg",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}


