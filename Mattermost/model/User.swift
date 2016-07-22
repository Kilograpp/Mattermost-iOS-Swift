
//
//  User.swift
//  Mattermost
//
//  Created by Maxim Gubin on 20/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift


class User: RealmObject {
    dynamic var email: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var identifier: String?
    dynamic var nickname: String?
    dynamic var username: String?
    dynamic var privateStatus: String?
    
    override static func indexedProperties() -> [String] {
        return [UserAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return UserAttributes.identifier.rawValue
    }
}

private protocol PathPatterns {
    static func loginPathPattern() -> String;
}

private protocol Mappings {
    static func mapping() -> RKObjectMapping
}

private protocol ResponseDescriptors {
    static func loginResponseDescriptor() -> RKResponseDescriptor
}

public enum UserAttributes: String {
    case privateStatus = "privateStatus"
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case identifier = "identifier"
    case nickname = "nickname"
    case status = "status"
    case username = "username"
}

extension User: PathPatterns {
    class func loginPathPattern() -> String {
        return "users/login";
    }
}

// MARK: - Mappings
extension User: Mappings {
    override class func mapping() -> RKObjectMapping {
        let entityMapping = super.mapping()
        entityMapping.addAttributeMappingsFromDictionary([
            "first_name" : UserAttributes.firstName.rawValue,
            "last_name"  : UserAttributes.lastName.rawValue
            ])
        return entityMapping
    }
    
}

// MARK: - Response Descriptors
extension User: ResponseDescriptors {
    class func loginResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                    method: .POST,
                                    pathPattern: loginPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}