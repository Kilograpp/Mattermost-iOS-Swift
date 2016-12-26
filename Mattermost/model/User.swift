
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
    func isPreferedDirectChannel() -> Bool
    func directChannel() -> Channel
    func hasChannel() -> Bool
    func notificationProperies() -> NotifyProps
}

final class User: RealmObject {
    dynamic var authData: String?
    dynamic var authService: String?
    dynamic var createAt: Date?
    dynamic var updateAt: Date?
    dynamic var deleteAt: Date?
    dynamic var email: String?
    dynamic var emailVerified: Bool = false
    dynamic var firstName: String?
    dynamic var identifier: String! {
        didSet { computeAvatarUrl() }
    }
    dynamic var lastName: String?
    dynamic var lastPasswordUdate: Date?
    dynamic var lastPictureUpdate: Date?
    dynamic var locale: String?
    dynamic var nickname: String?
    dynamic var notifyProps: NotifyProps?
    dynamic var roles: String?
    dynamic var username: String? {
        didSet { computeNicknameIfRequired() }
    }
    
    var preferences = List<Preference>()
    
    dynamic var displayNameWidth: Float = 0.0
    dynamic var avatarLink: String!
    dynamic var displayName: String? {
        didSet { computeDisplayNameWidth() }
    }
    dynamic var isOnTeam: Bool = false
    
    let channels = LinkingObjects(fromType: Channel.self, property: ChannelRelationships.members.rawValue)
    

    override static func indexedProperties() -> [String] {
        return [UserAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return UserAttributes.identifier.rawValue
    }
    
    func avatarURL() -> URL {
        return URL(string: self.avatarLink)!
    }
    func smallAvatarCacheKey() -> String {
        return self.avatarLink + "_small"
    }
}

enum UserAttributes: String {
    case authData          = "authData"
    case authService       = "authService"
    case createAt          = "createAt"
    case updateAt          = "updateAt"
    case deleteAt          = "deleteAt"
    case email             = "email"
    case emailVerified     = "emailVerified"
    case firstName         = "firstName"
    case identifier        = "identifier"
    case lastName          = "lastName"
    case lastPasswordUdate = "lastPasswordUdate"
    case lastPictureUpdate = "lastPictureUpdate"
    case locale            = "locale"
    case nickname          = "nickname"
    case notifyProps       = "notifyProps"
    case roles             = "roles"
    case username          = "username"
    
    case privateStatus     = "privateStatus"
    case status            = "status"
    case avatarLink        = "avatarLink"
}

enum UserRelationships: String {
    case notifyProps = "notifyProps"
}

private protocol Computatations: class {
    func computeDisplayNameWidth()
    func computeDisplayName()
    func computeAvatarUrl()
    func computeNicknameIfRequired()
}

extension User: Computatations {
    func computeNicknameIfRequired() {
        guard self.nickname == nil else { return }
        self.nickname = self.username
    }
    func computeDisplayNameWidth() {
        self.displayNameWidth = StringUtils.widthOfString(self.displayName as NSString!, font: FontBucket.postAuthorNameFont)
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
    
    func isPreferedDirectChannel() -> Bool {
        let channel = self.directChannel()
        guard channel != nil else { return false }
        
        return channel.isDirectPrefered
    }
    
    func directChannel() -> Channel {
        let realm = RealmUtils.realmForCurrentThread()
        return realm.objects(Channel.self).filter(NSPredicate(format: "name CONTAINS[c] %@", self.identifier)).first!
    }
    
    func hasChannel() -> Bool {
        let predicate =  NSPredicate(format: "displayName == %@", self.username!)
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate)
        return (channels.count > 0)
    }
    
    func notificationProperies() -> NotifyProps {
        let key = self.identifier! + "__notifyProps"
        let notifyProps = NotifyProps.objectById(key)
        return notifyProps!
    }
}
