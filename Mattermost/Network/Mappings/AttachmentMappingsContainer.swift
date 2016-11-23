//
//  AttachmentMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
}

final class AttachmentMappingsContainer: BaseMappingsContainer{
    override class var classForMapping: AnyClass! {
        return Attachment.self
    }
}

//MARK: ResponseMappings
extension AttachmentMappingsContainer: ResponseMappings {
    override static func mapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappings(from: [
            AttachmentAttributes.text.rawValue,
            AttachmentAttributes.color.rawValue,
            AttachmentAttributes.pretext.rawValue,
            AttachmentAttributes.fallback.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "fields",
            toKeyPath: AttachmentRelationship.fields.rawValue,
            with: AttachmentFieldMappingsContainer.mapping()))
        
        return mapping
    }
}
