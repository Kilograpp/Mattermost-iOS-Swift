//
//  AttachmentFieldMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit


final class AttachmentFieldMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return AttachmentField.self
    }
    
    override static func mapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappings(from: [
            AttachmentFieldAttributes.short.rawValue,
            AttachmentFieldAttributes.value.rawValue,
            AttachmentFieldAttributes.title.rawValue
            ])
        return mapping
    }
}
