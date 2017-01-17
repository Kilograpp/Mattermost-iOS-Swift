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
    static func getFileInfosMapping() -> RKObjectMapping
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
    static func getFileInfosMapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "create_at"         : FileAttributes.createAt.rawValue,
            "delete_at"         : FileAttributes.deleteAt.rawValue,
            "extension"         : FileAttributes.ext.rawValue,
            "mime_type"         : FileAttributes.mimeType.rawValue,
            "name"              : FileAttributes.name.rawValue,
            "post_id"           : FileAttributes.postId.rawValue,
            "size"              : FileAttributes.size.rawValue,
            "update_at"         : FileAttributes.updateAt.rawValue,
            "user_id"           : FileAttributes.userId.rawValue,
            
            "has_preview_image" : FileAttributes.hasPreview.rawValue,
            "height"            : FileAttributes.height.rawValue,
            "width"             : FileAttributes.width.rawValue
            ])
         return mapping
    }
    
    static func ezMapping() -> RKObjectMapping {
        let mp = super.emptyMapping()
        mp.addPropertyMapping(RKAttributeMapping(fromKeyPath: "identifier", toKeyPath: nil))
        
        return mp
    }
}
