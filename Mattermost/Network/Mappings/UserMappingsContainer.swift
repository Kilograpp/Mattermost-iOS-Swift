//
//  UserMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
    static func directProfileMapping() -> RKObjectMapping
}

final class UserMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return User.self
    }
}

//MARK: - ResponseMappings
extension UserMappingsContainer: ResponseMappings {
    
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappingsFromDictionary([
            "firstName" : UserAttributes.firstName.rawValue,
            "lastName"  : UserAttributes.lastName.rawValue,
            "username"   : UserAttributes.username.rawValue,
            "nickname"   : UserAttributes.nickname.rawValue,
            "email"      : UserAttributes.email.rawValue
            ])
        return mapping
    }

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