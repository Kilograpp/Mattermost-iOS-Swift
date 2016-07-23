//
//  File.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class File: RealmObject {
    dynamic var privateLink: String?
    dynamic var privateMimeType: String?
    dynamic var 
}

public enum FileAttributes: String {
    case privateLink = "privateLink"
    case privateMimeType = "privateMimeType"
    case fileExtension = "fileExtension"
    case hasPreviewImage = "hasPreviewImage"
    case localLink = "localLink"
    case name = "name"
    case size = "size"
}

public enum FileRelationships: String {
    case post = "post"
}