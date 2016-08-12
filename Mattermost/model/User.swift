
//
//  User.swift
//  Mattermost
//
//  Created by Maxim Gubin on 20/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol Interface {
    func isSystem() -> Bool
}

final class User: RealmObject {
    dynamic var email: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var identifier: String! {
        didSet { computeAvatarUrl() }
    }
    dynamic var nickname: String?
    dynamic var displayNameWidth: Float = 0.0
    dynamic var avatarLink: String!
    dynamic var displayName: String? {
        didSet { computeDisplayNameWidth() }
    }
    dynamic var username: String? {
        didSet { computeNicknameIfRequired() }
    }
    override static func indexedProperties() -> [String] {
        return [UserAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return UserAttributes.identifier.rawValue
    }
    
    func avatarURL() -> NSURL {
        return NSURL(string: self.avatarLink)!
    }
    func smallAvatarCacheKey() -> String {
        return self.avatarLink.stringByAppendingString("_small")
    }
}

enum UserAttributes: String {
    case privateStatus = "privateStatus"
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case identifier = "identifier"
    case nickname = "nickname"
    case status = "status"
    case username = "username"
    case avatarLink = "avatarLink"
}

private protocol PathPatterns: class {
    static func loginPathPattern() -> String
    static func avatarPathPattern() -> String
    static func socketPathPattern() -> String
    static func initialLoadPathPattern() -> String
    static func completeListPathPattern() -> String
    static func usersStatusPathPattern() -> String
}

private protocol Mappings: class {
    static func mapping() -> RKObjectMapping
    static func directProfileMapping() -> RKObjectMapping
}

private protocol ResponseDescriptors: class {
    static func loginResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor
    static func completeListResponseDescriptor() -> RKResponseDescriptor
}

private protocol Computatations: class {
    func computeDisplayNameWidth()
    func computeDisplayName()
    func computeAvatarUrl()
    func computeNicknameIfRequired()
}


extension User: PathPatterns {
    static func avatarPathPattern() -> String {
        return "users/:\(UserAttributes.identifier)/image"
    }
    static func loginPathPattern() -> String {
        return "users/login";
    }
    static func initialLoadPathPattern() -> String {
        return Team.initialLoadPathPattern()
    }
    static func socketPathPattern() -> String {
        return "users/websocket"
    }
    static func completeListPathPattern() -> String {
        return "users/profiles/:\(TeamAttributes.identifier)"
    }
    
    static func usersStatusPathPattern() -> String {
        return "users/status"
    }
}

// MARK: - Mappings
extension User: Mappings {
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

// MARK: - Response Descriptors
extension User: ResponseDescriptors {
    static func loginResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                    method: .POST,
                                    pathPattern: loginPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: directProfileMapping(),
                                    method: .GET,
                                    pathPattern: initialLoadPathPattern(),
                                    keyPath: "direct_profiles",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func completeListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: directProfileMapping(),
                                    method: .GET,
                                    pathPattern: completeListPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}

extension User: Computatations {
    func computeNicknameIfRequired() {
        guard self.nickname == nil else { return }
        self.nickname = self.username
    }
    func computeDisplayNameWidth() {
        self.displayNameWidth = StringUtils.widthOfString(self.displayName, font: FontBucket.postAuthorNameFont)
    }
    
    func computeAvatarUrl() {
        self.avatarLink = Api.sharedInstance.avatarLinkForUser(self)
    }
    
    func computeDisplayName() {
        self.displayName = self.username
    }
}

extension User: Interface {
    func isSystem() -> Bool {
        return self.identifier == Constants.Realm.SystemUserIdentifier
    }
}