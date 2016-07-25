//
//  Channel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class Channel: RealmObject {
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
    dynamic var lastPostDate: String?
    dynamic var displayName: String?
    
    
    dynamic var team: Team?
    
    let members = List<User>()
    
    override class func primaryKey() -> String {
        return ChannelAttributes.identifier.rawValue
    }
    override class func indexedProperties() -> [String] {
        return [ChannelAttributes.identifier.rawValue]
    }
    
}

public enum ChannelAttributes: String {
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

public enum ChannelRelationships: String {
    case team = "team"
    case members = "members"
}

private protocol PathPattern {
    static func listPathPattern() -> String
    static func extraInfoPathPattern() -> String
    static func updateLastViewDatePathPattern() -> String
}

private protocol Mapping {
    static func mapping() -> RKObjectMapping
    static func attendantInfoMapping() -> RKObjectMapping
}

private protocol ResponseDescriptors {
    static func extraInfoResponseDescriptor() -> RKResponseDescriptor
    static func channelsListResponseDescriptor() -> RKResponseDescriptor
    static func updateLastViewDataResponseDescriptor() -> RKResponseDescriptor
    static func channelsListMembersResponseDescriptor() -> RKResponseDescriptor
}


private protocol Support {
    static func teamIdentifierPath() -> String
}

// MARK: - Path Pattern
extension Channel: PathPattern {
    class func listPathPattern() -> String {
        return "teams/:\(ChannelAttributes.identifier.rawValue)/channels/"
    }
    class func extraInfoPathPattern() -> String {
        return "teams/:\(teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/extra_info"
    }
    class func updateLastViewDatePathPattern() -> String {
        return "teams/:\(teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/update_last_viewed_at"
    }
}

// MARK: - Mapping
extension Channel: Mapping {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappingsFromDictionary([
            "type"            : ChannelAttributes.privateType.rawValue,
            "team_id"         : ChannelAttributes.privateTeamId.rawValue,
            "create_at"       : ChannelAttributes.createdAt.rawValue,
            "display_name"    : ChannelAttributes.displayName.rawValue,
            "last_post_at"    : ChannelAttributes.lastPostDate.rawValue,
            "total_msg_count" : ChannelAttributes.messagesCount.rawValue
            ])
        mapping.addAttributeMappingsFromArray([
            ChannelAttributes.name.rawValue,
            ChannelAttributes.header.rawValue,
            ChannelAttributes.purpose.rawValue
            ])
        mapping.addRelationshipMappingWithSourceKeyPath(ChannelRelationships.members.rawValue, mapping: User.mapping())
        return mapping;
    }
    
    class func attendantInfoMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.assignsNilForMissingRelationships = false
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(ChannelAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(ChannelAttributes.identifier)).last_viewed_at" : ChannelAttributes.lastViewDate.rawValue
            ])
        return mapping
    }
}

// MARK: Response Descriptors
extension Channel: ResponseDescriptors {
    static func channelsListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                    method: .GET,
                                    pathPattern: listPathPattern(),
                                    keyPath: "channels",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func channelsListMembersResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: attendantInfoMapping(),
                                    method: .GET,
                                    pathPattern: listPathPattern(),
                                    keyPath: "members",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    static func extraInfoResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: mapping(),
                                    method: .GET,
                                    pathPattern: extraInfoPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    static func updateLastViewDataResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: emptyMapping(),
                                    method: .POST,
                                    pathPattern: updateLastViewDatePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}


//  MARK: - Support
extension Channel: Support {
    class func teamIdentifierPath() -> String {
        return ChannelRelationships.team.rawValue + "." + ChannelAttributes.identifier.rawValue
    }
    func computeTeam() {
        let team = Team()
        team.identifier = self.privateTeamId!.isEmpty ? DataManager.sharedInstance.currentTeam!.identifier : self.privateTeamId!
        self.team = team
    }
}