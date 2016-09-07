//
//  FileBase.swift
//  Mattermost
//
//  Created by Maxim Gubin on 24/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol Interface: class {
    func downloadURL() -> NSURL?
    func thumbURL() -> NSURL?
}

final class File: RealmObject {
    dynamic var name: String?
    dynamic var isImage: Bool = false
    var _downloadLink: String? {
        return FileUtils.downloadLinkForFile(self)?.absoluteString
    }
    var _thumbLink: String? {
        return FileUtils.thumbLinkForFile(self)?.absoluteString
    }
    dynamic var rawLink: String? {
        didSet {
            computeName()
            computeIsImage()
        }
    }
    private let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.files.rawValue)
    var post: Post?  {
        return self.posts.first
    }
    
    override class func primaryKey() -> String {
        return FileAttributes.name.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [FileAttributes.name.rawValue]
    }
}

enum FileAttributes: String {
    case isImage = "isImage"
    case rawLink = "rawLink"
    case name = "name"
}

enum FileRelationships: String {
    case post = "post"
}

//private protocol ResponseMappings: class {
//    static func simplifiedMapping() -> RKObjectMapping
//    static func uploadMapping() -> RKObjectMapping
//}

private protocol Computations: class {
    func computeName()
//    func computeDownloadLink()
//    func computeThumbLink()
    func computeIsImage()
}


private protocol Support: class {
    func thumbPostfix() -> String?
    static func teamIdentifierPath() -> String
}

//MARK: - MAPPING

//extension File: ResponseMappings {
//    static func simplifiedMapping() -> RKObjectMapping {
//        let mapping = super.emptyMapping()
//        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
//        return mapping
//    }
//    
//    static func uploadMapping() -> RKObjectMapping {
//        let mapping = RKObjectMapping(withClass: NSMutableDictionary.self)
//        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: FileAttributes.rawLink.rawValue))
//        
//        return mapping
//    }
//}

extension File: Computations {
    private func computeName() {
        let components = self.rawLink?.componentsSeparatedByString("/")
        if let components = components where components.count >= 2 {
            let fileName = components.last!.stringByRemovingPercentEncoding
            self.name = fileName
        } else {
            self.name = rawLink
        }
    }
//    
//    private func computeDownloadLink() {
//        self._downloadLink = FileUtils.downloadLinkForFile(self)?.absoluteString
//    }
//    
//    private func computeThumbLink() {
//        self._thumbLink = FileUtils.thumbLinkForFile(self)?.absoluteString
//    }
    
    private func computeIsImage() {
        self.isImage = FileUtils.fileIsImage(self)
    }
}

extension File: Support {
    func thumbPostfix() -> String? {
        return FileUtils.thumbPostfixForInternalFile(self)
    }
    static func teamIdentifierPath() -> String {
        return "\(FileRelationships.post).\(PostRelationships.channel).\(ChannelRelationships.team).\(TeamAttributes.identifier)"
    }
    
}

extension File: Interface {
    func downloadURL() -> NSURL? {
        return NSURL(string: self._downloadLink ?? StringUtils.emptyString())
    }
    func thumbURL() -> NSURL? {
        return NSURL(string: self._thumbLink ?? StringUtils.emptyString())
    }
}