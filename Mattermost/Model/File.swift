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
    fileprivate let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.files.rawValue)
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

extension File: Computations {
    fileprivate func computeName() {
        let components = self.rawLink?.components(separatedBy: "/")
        if let components = components , components.count >= 2 {
            let fileName = components.last!.removingPercentEncoding
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
    
    fileprivate func computeIsImage() {
        self.isImage = FileUtils.fileIsImage(self)
    }
    
    static func fileNameFromUrl(url:URL) -> String {
        let rawLink = url.absoluteString
            let components = rawLink.components(separatedBy: "/")
            if components.count >= 2 {
                let fileName = components.last!.removingPercentEncoding
                print(fileName)
                return fileName!
            } else {
                print(rawLink)
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
