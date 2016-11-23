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
    func downloadURL() -> URL?
    func thumbURL() -> URL?
}

final class File: RealmObject {
    dynamic var name: String?
    dynamic var ext: String?
    dynamic var hasPreview: Bool = false
    dynamic var mimeType: String?
    dynamic var size: Int = 0
    
    dynamic var identifier: String?
    dynamic var isImage: Bool = false
    var _downloadLink: String? { return FileUtils.downloadLinkForFile(self)?.absoluteString }
    var _thumbLink: String? { return FileUtils.thumbLinkForFile(self)?.absoluteString }
    dynamic var rawLink: String? {
        didSet {
            computeName()
            computeIsImage()
            computeIdentifierIfNeeded()
       //     Api.sharedInstance.getInfo(file: self)
        }
    }
    dynamic var localLink: String?
    dynamic var downoloadedSize: Int = 0
    fileprivate let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.files.rawValue)
    var post: Post?  { return self.posts.first }
    
    override class func primaryKey() -> String { return FileAttributes.identifier.rawValue }
    override class func indexedProperties() -> [String] { return [FileAttributes.identifier.rawValue] }
}

enum FileAttributes: String {
    case name       = "name"
    case ext        = "ext"
    case hasPreview = "hasPreview"
    case mimeType   = "mimeType"
    case size       = "size"
    
    case identifier = "identifier"
    case isImage    = "isImage"
    case rawLink    = "rawLink"
}

enum FileRelationships: String {
    case post = "post"
}

private protocol Computations: class {
    func computeName()
    func computeIsImage()
    func computeIdentifierIfNeeded()
}

private protocol Support: class {
    func thumbPostfix() -> String?
    static func teamIdentifierPath() -> String
}

extension File: Computations {
    fileprivate func computeIdentifierIfNeeded() {
        guard self.identifier == nil else { return }
        self.identifier = StringUtils.randomUUID()
    }
    fileprivate func computeName() {
        let components = self.rawLink?.components(separatedBy: "/")
        if let components = components , components.count >= 2 {
            let fileName = components.last!.removingPercentEncoding
            self.name = fileName
        } else {
            self.name = rawLink
        }
    }
    
    fileprivate func computeIsImage() {
        self.isImage = FileUtils.fileIsImage(self)
    }
    
    static func fileNameFromUrl(url:URL) -> String {
        let rawLink = url.absoluteString
            let components = rawLink.components(separatedBy: "/")
            if components.count >= 2 {
                let fileName = components.last!.removingPercentEncoding
                return fileName!
            } else {
                return rawLink
            }
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
    func downloadURL() -> URL? {
        return URL(string: self._downloadLink ?? StringUtils.emptyString())
    }
    func thumbURL() -> URL? {
        return URL(string: self._thumbLink ?? StringUtils.emptyString())
    }
}
