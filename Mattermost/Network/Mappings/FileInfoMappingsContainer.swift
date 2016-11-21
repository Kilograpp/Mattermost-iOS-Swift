//
//  FileInfoMappingsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 20.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
}

class FileInfoMappingsContainer: BaseMappingsContainer {

}


//MARK: ResponseMappings
extension FileInfoMappingsContainer: ResponseMappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(with: FileInfo.self)
        mapping?.addAttributeMappings(from: [
            "extension"         : FileInfoAttributes.ext.rawValue,
            "filename"          : FileInfoAttributes.name.rawValue,
            "has_preview_image" : FileInfoAttributes.hasPreview.rawValue,
            "mime_type"         : FileInfoAttributes.mimeType.rawValue,
            "size"              : FileInfoAttributes.size.rawValue
            ])
        return mapping!
    }
}
