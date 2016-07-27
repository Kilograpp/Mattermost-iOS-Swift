
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
    dynamic var nickname: String? {
        didSet {
            computeNicknameWidth()
        }
    }
    dynamic var nicknameWidth: Float = 0.0
    dynamic var username: String? {
        didSet {
            computeNicknameIfRequired()
        }
    }
    override static func indexedProperties() -> [String] {
        return [UserAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return UserAttributes.identifier.rawValue
    }
}

private protocol PathPatterns {
    static func loginPathPattern() -> String
    static func initialLoadPathPattern() -> String
}

private protocol Mappings {
    static func mapping() -> RKObjectMapping
    static func directProfileMapping() -> RKObjectMapping
}

private protocol ResponseDescriptors {
    static func loginResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor
}

private protocol Computatations {
    func computeNicknameWidth()
    func computeNicknameIfRequired()
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
    class func initialLoadPathPattern() -> String {
        return Team.initialLoadPathPattern()
    }
}

// MARK: - Mappings
extension User: Mappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappingsFromDictionary([
            "first_name" : UserAttributes.firstName.rawValue,
            "last_name"  : UserAttributes.lastName.rawValue
            ])
        return mapping
    }
    class func directProfileMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(UserAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(UserAttributes.identifier)).first_name" : UserAttributes.firstName.rawValue,
            "(\(UserAttributes.identifier)).last_name" : UserAttributes.lastName.rawValue,
            "(\(UserAttributes.identifier)).username" : UserAttributes.username.rawValue,
            "(\(UserAttributes.identifier)).email" : UserAttributes.email.rawValue
        ])
        return mapping
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
    class func initialLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: directProfileMapping(),
                                    method: .GET,
                                    pathPattern: initialLoadPathPattern(),
                                    keyPath: "direct_profiles",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}

extension User: Computatations {
    func computeNicknameIfRequired() {
        if self.nickname == nil {
            self.nickname = self.username
        }
    }
    func computeNicknameWidth() {
        self.nicknameWidth = StringUtils.widthOfString(self.nickname, font: UIFont.systemFontOfSize(12))
    }
}