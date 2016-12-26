//
//  ChannelMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestMapping: class {
    static func createRequestMapping() -> RKObjectMapping
}

private protocol ResponseMappings: class {
    static func attendantInfoMapping() -> RKObjectMapping
}

// Sadly no generics for Runtime methods scanning 
// http://stackoverflow.com/a/31362180
final class ChannelMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Channel.self
    }
}


//MARK: RequestMapping
extension ChannelMappingsContainer: RequestMapping {
    static func  createRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        mapping?.addAttributeMappings(from: [
            ChannelAttributes.name.rawValue        : "name",
            ChannelAttributes.privateType.rawValue : "type",
            ChannelAttributes.displayName.rawValue : "display_name",
            ChannelAttributes.header.rawValue      : "header",
            ChannelAttributes.purpose.rawValue     : "purpose",
            ChannelAttributes.creatorId.rawValue   : "creator_id"
            ])
        return mapping!
    }
    
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "create_at"       : ChannelAttributes.createdAt.rawValue,
            "update_at"       : ChannelAttributes.updateAt.rawValue,
            "delete_at"       : ChannelAttributes.deleteAt.rawValue,
            "team_id"         : ChannelAttributes.privateTeamId.rawValue,
            "type"            : ChannelAttributes.privateType.rawValue,
            "display_name"    : ChannelAttributes.displayName.rawValue
            ])
        mapping.addAttributeMappings(from: [
            ChannelAttributes.name.rawValue,
            ChannelAttributes.header.rawValue,
            ChannelAttributes.purpose.rawValue
            ])
        mapping.addAttributeMappings(from: [
            "last_post_at"    : ChannelAttributes.lastPostDate.rawValue,
            "total_msg_count" : ChannelAttributes.messagesCount.rawValue,
            "extra_update_at" : ChannelAttributes.extraUpdateDate.rawValue,
            "creator_id"      : ChannelAttributes.creatorId.rawValue
            ])
        
     //   mapping.addRelationshipMapping(withSourceKeyPath: ChannelRelationships.members.rawValue, mapping: UserMappingsContainer.mapping())
        return mapping;
    }
}


//MARK: ResponseMappings
extension ChannelMappingsContainer: ResponseMappings {
    static func attendantInfoMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.assignsNilForMissingRelationships = false
        mapping.addAttributeMappingFromKeyOfRepresentation(toAttribute: ChannelAttributes.identifier.rawValue)
        mapping.addAttributeMappings(from: [
            "(\(ChannelAttributes.identifier)).last_viewed_at" : ChannelAttributes.lastViewDate.rawValue
            ])
        return mapping
    }
}

