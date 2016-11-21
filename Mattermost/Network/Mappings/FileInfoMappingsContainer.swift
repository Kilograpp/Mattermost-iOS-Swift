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
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "user_id"           : FileInfoAttributes.userId.rawValue,
            "post_id"           : FileInfoAttributes.postId.rawValue,
            "create_at"         : FileInfoAttributes.createAt.rawValue,
            "update_at"         : FileInfoAttributes.updateAt.rawValue,
            "delete_at"         : FileInfoAttributes.deleteAt.rawValue,
            "name"              : FileInfoAttributes.name.rawValue,
            "extension"         : FileInfoAttributes.ext.rawValue,
            "size"              : FileInfoAttributes.size.rawValue,
            "mime_type"         : FileInfoAttributes.mimeType.rawValue,
            "width"             : FileInfoAttributes.width.rawValue,
            "height"            : FileInfoAttributes.height.rawValue,
            "has_preview_image" : FileInfoAttributes.hasPreview.rawValue
            ])
        return mapping
    }
}
