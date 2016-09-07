//
//  UserMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol Mappings: class {
    static func mapping() -> RKObjectMapping
    static func directProfileMapping() -> RKObjectMapping
}

final class UserMappingsContainer: BaseMappingsContainer {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappingsFromDictionary([
            "first_name" : UserAttributes.firstName.rawValue,
            "last_name"  : UserAttributes.lastName.rawValue,
            "username"   : UserAttributes.username.rawValue,
            "nickname"   : UserAttributes.nickname.rawValue
            ])
        return mapping
    }
}

extension UserMappingsContainer: Mappings {

    static func directProfileMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(UserAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(UserAttributes.identifier)).first_name" : UserAttributes.firstName.rawValue,
            "(\(UserAttributes.identifier)).last_name" : UserAttributes.lastName.rawValue,
            "(\(UserAttributes.identifier)).username" : UserAttributes.username.rawValue,
            "(\(UserAttributes.identifier)).nickname" : UserAttributes.nickname.rawValue,
            "(\(UserAttributes.identifier)).email" : UserAttributes.email.rawValue
            ])
        return mapping
    }
    
}