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
    case identifier      = "identifier"
    case createdAt       = "createdAt"
    case updateAt        = "updateAt"
    case deleteAt        = "deleteAt"
    case privateTeamId   = "privateTeamId"
    case privateType     = "privateType"
    case displayName     = "displayName"
    case name            = "name"
    case header          = "header"
    case purpose         = "purpose"
    case lastPostDate    = "lastPostDate"
    case messagesCount   = "messagesCount"
    case extraUpdateDate = "extraUpdateDate"
    case creatorId       = "creatorId"
    
    case lastViewDate  = "lastViewDate"
}

enum ChannelRelationships: String {
    case team    = "team"
    case members = "members"
}

private enum PrivateType {
    case direct
    case publicChannel
    case privateChannel
}

private protocol Computatations: class {
    func computeDisplayNameWidth()
}

final class Channel: RealmObject {
    
    class func privateTypeDisplayName(_ privateTypeString: String) -> String {
        switch privateTypeString {
        case Constants.ChannelType.PublicTypeChannel:
            return "Public channels"
        case Constants.ChannelType.PrivateTypeChannel:
            return "Private groups"
        case Constants.ChannelType.DirectTypeChannel:
            return "Direct message"
        case "out":
            return "Outside this team"
        default:
            return "UNKNOWN"
        }
    }
    
    dynamic var identifier: String?
    dynamic var createdAt: Date?
    dynamic var updateAt: Date?
    dynamic var deleteAt: Date?
    dynamic var privateTeamId: String? {
        didSet { computeTeam() }
    }
    dynamic var privateType: String?
    dynamic var displayName: String? {
        didSet { computeDisplayNameWidth() }
    }
    dynamic var name: String?
    dynamic var header: String?
    dynamic var purpose: String?
    dynamic var lastPostDate: Date?
    dynamic var messagesCount: String?
    dynamic var extraUpdateDate: Date?
    dynamic var creatorId: String?
    
    
    dynamic var lastViewDate: Date?
    
    dynamic var team: Team?
    dynamic var displayNameWidth: Float = 0.0
    dynamic var currentUserInChannel: Bool = false
    dynamic var isInterlocuterOnTeam: Bool = false
    dynamic var isDirectPrefered: Bool = false
    
    var isSelected: Bool {
        return self == ChannelObserver.sharedObserver.selectedChannel
    }
    
    var members = List<User>()
    
    func interlocuterFromPrivateChannel() -> User {
        let ids = self.name?.components(separatedBy: "__")
        let interlocuterId = ids?.first == Preferences.sharedInstance.currentUserId ? ids?.last : ids?.first
        return safeRealm.objects(User.self).filter(NSPredicate(format: "identifier = %@", interlocuterId!)).first!
    }
    
    override class func primaryKey() -> String {
        return ChannelAttributes.identifier.rawValue
    }
    override class func indexedProperties() -> [String] {
        return [ChannelAttributes.identifier.rawValue]
    }
    
    static func townSquare() -> Channel? {
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter("name == %@", "town-square")
        return (channels.count > 0) ? channels.first : nil
    }
    
    static func isUserInChannelWith(channelId: String) -> Bool {
        let realm = RealmUtils.realmForCurrentThread()
        let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId)
        
        guard channel != nil else { return false }
        
        return (channel?.members.contains(DataManager.sharedInstance.currentUser!))!
    }
}

private protocol Support: class {
    static func teamIdentifierPath() -> String
    func hasNewMessages() -> Bool
}

private protocol URLBuilder: class {
    func buildURL() -> String
}

//  MARK: - Support
extension Channel: Support {
    static func teamIdentifierPath() -> String {
        return ChannelRelationships.team.rawValue + "." + ChannelAttributes.identifier.rawValue
    }

    func computeTeam() {
        //s3 refactor
        if (self.privateTeamId!.isEmpty) {
            self.team = safeRealm.object(ofType:Team.self, forPrimaryKey: DataManager.sharedInstance.currentTeam!.identifier!)
        } else {
            self.team = safeRealm.object(ofType:Team.self, forPrimaryKey: self.privateTeamId!)
        }
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
        guard lastViewDate != nil else { return false }
        return ((self.lastViewDate as NSDate?)?.isEarlierThan(self.lastPostDate))!
    }
}

extension Channel: Computatations {
    func computeDisplayNameWidth() {
        self.displayNameWidth = StringUtils.widthOfString(self.displayName! as NSString!, font: FontBucket.postAuthorNameFont)
    }
}

extension Channel: URLBuilder {
    func buildURL() -> String {
        let baseUrlArr: [String] = Api.sharedInstance.baseURL().relativeString.components(separatedBy: "/")
        return baseUrlArr[0]+"//"+baseUrlArr[2]+"/"+self.team!.name!+"/channels/"+self.name!
    }
}
