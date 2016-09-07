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
    
}

extension AttachmentMappingsContainer: ResponseMappings {
    override static func mapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingsFromArray([
            AttachmentAttributes.text.rawValue,
            AttachmentAttributes.color.rawValue,
            AttachmentAttributes.pretext.rawValue,
            AttachmentAttributes.fallback.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "fields",
            toKeyPath: AttachmentRelationship.fields.rawValue,
            withMapping: AttachmentFieldMappingsContainer.mapping()))
        
        return mapping
    }
}