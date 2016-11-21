//
//  FileInfo.swift
//  Mattermost
//
//  Created by TaHyKu on 20.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class FileInfo: RealmObject {
    dynamic var userId: String?
    dynamic var postId: String?
    dynamic var createAt: Int = 0
    dynamic var updateAt: Int = 0
    dynamic var deleteAt: Int = 0
    dynamic var name: String?
    dynamic var ext: String?
    dynamic var size: Int = 0
    dynamic var mimeType: String?
    dynamic var width: Int = 0
    dynamic var height: Int = 0
    dynamic var hasPreview: Bool = false
}

public enum FileInfoAttributes: String {
    case userId     = "userId"
    case postId     = "postId"
    case createAt   = "createAt"
    case updateAt   = "updateAt"
    case deleteAt   = "deleteAt"
    case name       = "name"
    case ext        = "ext"
    case size       = "size"
    case mimeType   = "mimeType"
    case width      = "width"
    case height     = "height"
    case hasPreview = "hasPreview"
}
