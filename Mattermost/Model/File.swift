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
    //Common
    dynamic var createAt: Date?
    dynamic var deleteAt: Date?
    dynamic var ext: String?
    dynamic var identifier: String?
    dynamic var mimeType: String?
    dynamic var name: String? {
        didSet {
            computeIsImage()
            computeRawLink()
        }
    }
    dynamic var postId: String?
    dynamic var size: Int = 0
    dynamic var updateAt: Date?
    dynamic var userId: String?
    //Image
    dynamic var hasPreview: Bool = false
    dynamic var height: Int = 0
    dynamic var width: Int = 0
    
    
    
    dynamic var isImage: Bool = false
    var _downloadLink: String? { return FileUtils.downloadLinkForFile(self)?.absoluteString }
    var _thumbLink: String? { return FileUtils.thumbLinkForFile(self)?.absoluteString }
    dynamic var rawLink: String?/* {
        didSet {
            computeName()
            computeIsImage()
            computeIdentifierIfNeeded()
           // Api.sharedInstance.getInfo(fileId: self.identifier!)
        }
    }*/
    dynamic var localLink: String?
    dynamic var downoloadedSize: Int = 0
    fileprivate let posts = LinkingObjects(fromType: Post.self, property: PostRelationships.files.rawValue)
    var post: Post?  { return self.posts.first }
    
    override class func primaryKey() -> String { return FileAttributes.identifier.rawValue }
    override class func indexedProperties() -> [String] { return [FileAttributes.identifier.rawValue] }
}

enum FileAttributes: String {
    case createAt   = "createAt"
    case deleteAt   = "deleteAt"
    case ext        = "ext"
    case identifier = "identifier"
    case mimeType   = "mimeType"
    case name       = "name"
    case postId     = "postId"
    case size       = "size"
    case updateAt   = "updateAt"
    case userId     = "userId"
    
    case hasPreview = "hasPreview"
    case height     = "height"
    case width      = "width"
    
    case isImage    = "isImage"
    case rawLink    = "rawLink"
    //https://mattermost.kilograpp.com/api/v3/files/9ow9r1uke3bmbxursj8y4nnd5r/get -- file download link example
}

enum FileRelationships: String {
    case post = "post"
}

fileprivate protocol Computations: class {
    //func computeName()
    func computeIsImage()
    func computeRawLink()
    //func computeIdentifierIfNeeded()
}

private protocol Support: class {
   // func thumbPostfix() -> String?
    static func teamIdentifierPath() -> String
}

extension File: Computations {
    func computeIsImage() {
        self.isImage = FileUtils.fileIsImage(self)
    }
    func computeRawLink() {
        self.rawLink = String(format: "https://mattermost.kilograpp.com/api/v3/files/%@", self.identifier!)
    }
    
/*    func computeIdentifierIfNeeded() {
        guard self.identifier == nil else { return }
        self.identifier = StringUtils.randomUUID()
    }
    func computeName() {
        let components = self.rawLink?.components(separatedBy: "/")
        if let components = components , components.count >= 2 {
            let fileName = components.last!.removingPercentEncoding
            self.name = fileName
        } else {
            self.name = rawLink
        }
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
    }*/
}

extension File: Support {
  /*  func thumbPostfix() -> String? {
        return FileUtils.thumbPostfixForInternalFile(self)
    }*/
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
