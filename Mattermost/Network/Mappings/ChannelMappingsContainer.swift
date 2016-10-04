//
//  ChannelMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
    static func attendantInfoMapping() -> RKObjectMapping
}

// Sadly no generics for Runtime methods scanning 
// http://stackoverflow.com/a/31362180
final class ChannelMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Channel.self
    }
}

//MARK: - ResponseMappings
extension ChannelMappingsContainer: ResponseMappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "type"            : ChannelAttributes.privateType.rawValue,
            "team_id"         : ChannelAttributes.privateTeamId.rawValue,
            "create_at"       : ChannelAttributes.createdAt.rawValue,
            "display_name"    : ChannelAttributes.displayName.rawValue,
            "last_post_at"    : ChannelAttributes.lastPostDate.rawValue,
            "total_msg_count" : ChannelAttributes.messagesCount.rawValue
            ])
        mapping.addAttributeMappings(from: [
            ChannelAttributes.name.rawValue,
            ChannelAttributes.header.rawValue,
            ChannelAttributes.purpose.rawValue
            ])
        mapping.addRelationshipMapping(withSourceKeyPath: ChannelRelationships.members.rawValue, mapping: UserMappingsContainer.mapping())
        return mapping;
    }
    
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

