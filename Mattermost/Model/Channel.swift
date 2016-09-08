//
//  Channel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

enum ChannelAttributes: String {
    case identifier = "identifier"
    case createdAt = "createdAt"
    case privateTeamId = "privateTeamId"
    case lastViewDate = "lastViewDate"
    case name = "name"
    case displayName = "displayName"
    case purpose = "purpose"
    case header = "header"
    case messagesCount = "messagesCount"
    case lastPostDate = "lastPostDate"
    case privateType = "privateType"
}

enum ChannelRelationships: String {
    case team = "team"
    case members = "members"
  //  case posts = "posts"
}

private enum PrivateType {
    case Direct
    case PublicChannel
    case PrivateChannel
}

final class Channel: RealmObject {
    
    class func privateTypeDisplayName(privateTypeString: String) -> String {
        switch privateTypeString {
        case Constants.ChannelType.PrivateTypeChannel:
            return "Private message"
        case Constants.ChannelType.PublicTypeChannel:
            return "Public channel"
        default:
            return "UNKNOWN"
        }
    }
    
    dynamic var privateType: String?
    dynamic var privateTeamId: String? {
        didSet {
            computeTeam()
        }
    }
    dynamic var createdAt: NSDate?
    dynamic var lastViewDate: NSDate?
    dynamic var identifier: String?
    dynamic var name: String?
    dynamic var purpose: String?
    dynamic var header: String?
    dynamic var messagesCount: String?
    dynamic var lastPostDate: NSDate?
    dynamic var displayName: String?
    dynamic var currentUserInChannel: Bool = false
    
    dynamic var team: Team?
    
    var isSelected: Bool {
        return self == ChannelObserver.sharedObserver.selectedChannel
    }
    
    let members = List<User>()
   // let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.channel.rawValue)
    
    func interlocuterFromPrivateChannel() -> User {
        let ids = self.name?.componentsSeparatedByString("__")
        let interlocuterId = ids?.first == Preferences.sharedInstance.currentUserId ? ids?.last : ids?.first
        let user = safeRealm.objects(User).filter(NSPredicate(format: "identifier = %@", interlocuterId!)).first!
        return user
    }
    
    override class func primaryKey() -> String {
        return ChannelAttributes.identifier.rawValue
    }
    override class func indexedProperties() -> [String] {
        return [ChannelAttributes.identifier.rawValue]
    }
    
}

private protocol Support: class {
    static func teamIdentifierPath() -> String
    func hasNewMessages() -> Bool
}

//  MARK: - Support
extension Channel: Support {
    static func teamIdentifierPath() -> String {
        return ChannelRelationships.team.rawValue + "." + ChannelAttributes.identifier.rawValue
    }

    func computeTeam() {
        self.team = safeRealm.objectForPrimaryKey(Team.self, key: self.privateTeamId!.isEmpty ? DataManager.sharedInstance.currentTeam!.identifier : self.privateTeamId!)
    }
    
    func computeDispayNameIfNeeded() {
        if self.privateType == "D" {
            if !(self.name?.isEmpty)! {
                let user = self.interlocuterFromPrivateChannel()
                self.displayName = user.displayName
            }
        }
    }
    
    func hasNewMessages() -> Bool {
      return (self.lastViewDate?.isEarlierThan(self.lastPostDate))!
    }
}