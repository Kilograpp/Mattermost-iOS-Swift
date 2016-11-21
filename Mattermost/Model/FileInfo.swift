//
//  FileInfo.swift
//  Mattermost
//
//  Created by TaHyKu on 20.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class FileInfo: RealmObject {
    dynamic var name: String?
    dynamic var ext: String?
    dynamic var hasPreview: Bool = false
    dynamic var mimeType: String?
    dynamic var size: Int = 0
}

public enum FileInfoAttributes: String {
    case name       = "name"
    case ext        = "ext"
    case hasPreview = "hasPreview"
    case mimeType   = "mimeType"
    case size       = "size"
}
