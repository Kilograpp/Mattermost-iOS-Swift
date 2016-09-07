//
//  PostMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
        static func listMapping() -> RKObjectMapping
        static func creationMapping() -> RKObjectMapping
}

private protocol RequestMapping: class {
    static func creationRequestMapping() -> RKObjectMapping
}


final class PostMappingsContainer: BaseMappingsContainer {
    
}

//MARK: - ResponseMappings
extension PostMappingsContainer: ResponseMappings {
    class func creationMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingsFromDictionary([
            "id"                : PostAttributes.identifier.rawValue,
            "pending_post_id"   : PostAttributes.pendingId.rawValue,
            "message"           : PostAttributes.message.rawValue,
            "create_at"         : PostAttributes.createdAt.rawValue,
            "update_at"         : PostAttributes.updatedAt.rawValue,
            "files.backendLink" : "filenames"
            ])
        return mapping
    }
    class func listMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.assignsNilForMissingRelationships = false
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(PostAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(PostAttributes.identifier)).create_at" : PostAttributes.createdAt.rawValue,
            "(\(PostAttributes.identifier)).update_at" : PostAttributes.updatedAt.rawValue,
            "(\(PostAttributes.identifier)).message" : PostAttributes.message.rawValue,
            "(\(PostAttributes.identifier)).type" : PostAttributes.type.rawValue,
            "(\(PostAttributes.identifier)).user_id" : PostAttributes.authorId.rawValue,
            "(\(PostAttributes.identifier)).channel_id" : PostAttributes.channelId.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).filenames",
            toKeyPath: PostRelationships.files.rawValue,
            withMapping: FileMappingsContainer.simplifiedMapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).props.attachments",
            toKeyPath: PostRelationships.attachments.rawValue,
            withMapping: AttachmentMappingsContainer.mapping()))
        return mapping
    }
}

// MARK: - RequestMapping
extension PostMappingsContainer: RequestMapping {
    static func creationRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromArray([ "message" ])
        mapping.addAttributeMappingsFromDictionary([
            Post.filesLinkPath() : "filenames",
            PostAttributes.channelId.rawValue : "channel_id",
            PostAttributes.pendingId.rawValue : "pending_post_id",
            ])
        return mapping
    }
}
