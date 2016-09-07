//
//  AttachmentFieldMappingsContainer.swift
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

final class AttachmentFieldMappingsContainer: BaseMappingsContainer {
    
}

extension AttachmentFieldMappingsContainer: ResponseMappings {
    override static func mapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingsFromArray([
            AttachmentFieldAttributes.short.rawValue,
            AttachmentFieldAttributes.value.rawValue,
            AttachmentFieldAttributes.title.rawValue
            ])
        return mapping
    }
}