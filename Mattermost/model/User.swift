
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
    func isSelectedDirectChannel() -> Bool
    func directChannel() -> Channel?
    func hasChannel() -> Bool
    func notificationProperies() -> NotifyProps
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
    dynamic var createAt: Date?
    dynamic var updateAt: Date?
    dynamic var deleteAt: Date?
    dynamic var isOnTeam: Bool = false
    
    let channels = LinkingObjects(fromType: Channel.self, property: ChannelRelationships.members.rawValue)
    //let notifyProps = NotifyProps()
    dynamic var notifyProps: NotifyProps?
    dynamic var username: String? {
        didSet { computeNicknameIfRequired() }
    }
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
    case privateStatus = "privateStatus"
    case email         = "email"
    case firstName     = "firstName"
    case lastName      = "lastName"
    case identifier    = "identifier"
    case nickname      = "nickname"
    case status        = "status"
    case username      = "username"
    case avatarLink    = "avatarLink"
    case notifyProps   = "notifyProps"
    case createAt      = "createAt"
    case updateAt      = "updateAt"
    case deleteAt      = "deleteAt"
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
    
    func isSelectedDirectChannel() -> Bool {
        let channel = self.directChannel()
        guard channel != nil else { return false }
        
        return channel!.currentUserInChannel
    }
    
    func directChannel() -> Channel? {
        let predicate =  NSPredicate(format: "displayName == %@", self.username!)
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate)
        return (channels.count > 0) ? channels.first : nil
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
