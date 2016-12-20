//
//  UserMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit


private protocol RequestMapping: class {
    static func updateRequestMapping() -> RKObjectMapping
}

private protocol ResponseMappings: class {
    static func directProfileMapping() -> RKObjectMapping
    static func idsMapping() -> RKObjectMapping
}


final class UserMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return User.self
    }
    
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "create_at"    : UserAttributes.createAt.rawValue,
            "update_at"    : UserAttributes.updateAt.rawValue,
            "delete_at"    : UserAttributes.deleteAt.rawValue,
            "username"     : UserAttributes.username.rawValue,
            "auth_data"    : UserAttributes.authData.rawValue,
            "auth_service" : UserAttributes.authService.rawValue,
            "email"        : UserAttributes.email.rawValue,
            "nickname"     : UserAttributes.nickname.rawValue,
            "firstName"    : UserAttributes.firstName.rawValue,
            "lastName"     : UserAttributes.lastName.rawValue,
            "roles"        : UserAttributes.roles.rawValue,
            "locale"       : UserAttributes.locale.rawValue
            ])
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "notify_props",
                                                         toKeyPath: UserAttributes.notifyProps.rawValue,
                                                         with: NotifyPropsMappingsContainer.mapping()))
        return mapping
    }
    
    static func idsMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(with: NSMutableDictionary.self)
        return mapping!
    }
}


//MARK: RequestMapping
extension UserMappingsContainer: RequestMapping {
    static func updateRequestMapping() -> RKObjectMapping {
        let mapping = super.request()
        mapping.addAttributeMappings(from: [
            UserAttributes.email.rawValue      : "email",
            UserAttributes.firstName.rawValue  : "first_name",
            UserAttributes.lastName.rawValue   : "last_name",
            UserAttributes.nickname.rawValue   : "nickname",
            UserAttributes.username.rawValue   : "username",
            UserAttributes.createAt.rawValue   : "create_at",
            UserAttributes.updateAt.rawValue   : "update_at",
            UserAttributes.deleteAt.rawValue   : "delete_at"
            ])
        return mapping
    }
}


//MARK: ResponseMappings
extension UserMappingsContainer: ResponseMappings {
    static func directProfileMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.addAttributeMappingFromKeyOfRepresentation(toAttribute: UserAttributes.identifier.rawValue)
        mapping.addAttributeMappings(from: [
            "(\(UserAttributes.identifier)).first_name" : UserAttributes.firstName.rawValue,
            "(\(UserAttributes.identifier)).last_name"  : UserAttributes.lastName.rawValue,
            "(\(UserAttributes.identifier)).username"   : UserAttributes.username.rawValue,
            "(\(UserAttributes.identifier)).nickname"   : UserAttributes.nickname.rawValue,
            "(\(UserAttributes.identifier)).email"      : UserAttributes.email.rawValue,
            "(\(UserAttributes.identifier)).create_at"  : UserAttributes.createAt.rawValue,
            "(\(UserAttributes.identifier)).delete_at"  : UserAttributes.deleteAt.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "notify_props",
                                                         toKeyPath: UserAttributes.notifyProps.rawValue,
                                                         with: NotifyPropsMappingsContainer.mapping()))
        return mapping
    }
}
