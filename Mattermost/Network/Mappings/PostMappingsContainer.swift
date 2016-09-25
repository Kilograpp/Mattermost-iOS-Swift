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
        static func updatingMapping() -> RKObjectMapping
        static func deletingMapping() -> RKObjectMapping
}

private protocol RequestMapping: class {
    static func postRequestMapping() -> RKObjectMapping
   // static func creationRequestMapping() -> RKObjectMapping
   // static func updatingRequestMapping() -> RKObjectMapping
}


final class PostMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Post.self
    }
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
            "root_id"           : PostAttributes.rootId.rawValue,
            "parent_id"         : PostAttributes.parentId.rawValue,
            "user_id"           : PostAttributes.authorId.rawValue,
            "channel_id"        : PostAttributes.channelId.rawValue,
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
            "(\(PostAttributes.identifier)).create_at"  : PostAttributes.createdAt.rawValue,
            "(\(PostAttributes.identifier)).update_at"  : PostAttributes.updatedAt.rawValue,
            "(\(PostAttributes.identifier)).message"    : PostAttributes.message.rawValue,
            "(\(PostAttributes.identifier)).type"       : PostAttributes.type.rawValue,
            "(\(PostAttributes.identifier)).user_id"    : PostAttributes.authorId.rawValue,
            "(\(PostAttributes.identifier)).channel_id" : PostAttributes.channelId.rawValue,
            "(\(PostAttributes.identifier)).root_id"    : PostAttributes.rootId.rawValue,
            "(\(PostAttributes.identifier)).parent_id"  : PostAttributes.parentId.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).filenames",
            toKeyPath: PostRelationships.files.rawValue,
            withMapping: FileMappingsContainer.simplifiedMapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).props.attachments",
            toKeyPath: PostRelationships.attachments.rawValue,
            withMapping: AttachmentMappingsContainer.mapping()))
        return mapping
    }
    
    class func updatingMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.assignsNilForMissingRelationships = false
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(PostAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(PostAttributes.identifier)).update_at"  : PostAttributes.updatedAt.rawValue,
            "(\(PostAttributes.identifier)).message"    : PostAttributes.message.rawValue,
            "(\(PostAttributes.identifier)).channel_id" : PostAttributes.channelId.rawValue,
            "(\(PostAttributes.identifier)).root_id"    : PostAttributes.rootId.rawValue,
            "(\(PostAttributes.identifier)).parent_id"  : PostAttributes.parentId.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).filenames",
            toKeyPath: PostRelationships.files.rawValue,
            withMapping: FileMappingsContainer.simplifiedMapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).props.attachments",
            toKeyPath: PostRelationships.attachments.rawValue,
            withMapping: AttachmentMappingsContainer.mapping()))
        return mapping
    }
    
    class func deletingMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(PostAttributes.identifier.rawValue)
        return mapping
    }
}

// MARK: - RequestMapping
extension PostMappingsContainer: RequestMapping {
    static func postRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromArray([ "message" ])
        mapping.addAttributeMappingsFromDictionary([
            PostAttributes.identifier.rawValue : "id",
            Post.filesLinkPath()               : "filenames",
            PostAttributes.channelId.rawValue  : "channel_id",
            PostAttributes.pendingId.rawValue  : "pending_post_id",
            PostAttributes.parentId.rawValue   : "parent_id",
            PostAttributes.rootId.rawValue     : "root_id"
            ])
        return mapping
    }
}
