
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
    func hasChannel() -> Bool
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

    let channels = LinkingObjects(fromType: Channel.self, property: ChannelRelationships.members.rawValue)
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
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case identifier = "identifier"
    case nickname = "nickname"
    case status = "status"
    case username = "username"
    case avatarLink = "avatarLink"
}

/*enum UserRelationships: String {
    case notifyProps = "notify_props"
}*/

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
    
    func hasChannel() -> Bool {
        let predicate =  NSPredicate(format: "displayName == %@", self.username!)
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate)
        return (channels.count > 0)
    }
}
