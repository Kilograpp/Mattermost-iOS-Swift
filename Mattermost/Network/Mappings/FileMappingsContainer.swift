//
//  FileMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func simplifiedMapping() -> RKObjectMapping
    static func uploadMapping() -> RKObjectMapping
    static func getInfoMapping() -> RKObjectMapping
}


final class FileMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return File.self
    }
}


//MARK: ResponseMappings
extension FileMappingsContainer: ResponseMappings {
    static func simplifiedMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
        return mapping
    }
    static func uploadMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(with: NSMutableDictionary.self)
        mapping?.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
        return mapping!
    }
    static func getInfoMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappings(from: [
            "filename"          : FileAttributes.name.rawValue,
            "extension"         : FileAttributes.ext.rawValue,
            "size"              : FileAttributes.size.rawValue,
            "mime_type"         : FileAttributes.mimeType.rawValue,
            "has_preview_image" : FileAttributes.hasPreview.rawValue
            ])
         return mapping
    }
}
