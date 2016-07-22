//
//  Post.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import TSMarkdownParser

class Post: RealmObject {
    dynamic var privatePendingId: String?
    dynamic var privateChannelId: String?
    dynamic var privateAuthorId: String?
    dynamic var creationDay: NSDate?
    dynamic var createdAt: NSDate? {
        didSet {computeDisplayDay()}
    }
    dynamic var createdAtString: String? {
        didSet {computeCreatedAtStringWidth()}
    }
    dynamic var createdAtStringWidth: Float = 0.0
    dynamic var updatedAt: NSDate?
    dynamic var deletedAt: NSDate?
    dynamic var identifier: String?
    dynamic var message: String? {
        didSet {computeAttributedString()}
    }
    dynamic var attributedMessage: NSAttributedString? {
        didSet {computeAttributedMessageHeight()}
    }
    dynamic var attributedMessageHeight: Float = 0.0
    dynamic var type: String?
    
    let files = List<File>()
    
    override class func primaryKey() -> String {
        return PostAttributes.identifier.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [PostAttributes.identifier.rawValue]
    }
}

private protocol PathPattern {
    static func updatePathPattern() -> String
    static func nextPagePathPattern() -> String
    static func creationPathPattern() -> String
    static func firstPagePathPattern() -> String
}

private protocol Mapping {
    static func listMapping() -> RKObjectMapping
    static func creationMapping() -> RKObjectMapping
}

private protocol RequestMapping {
    static func creationRequestMapping() -> RKObjectMapping
}

private protocol Support {
    static func filesLinkPath() -> String
}

public enum PostAttributes: String {
    case privatePendingId = "privatePendingId"
    case privateChannelId = "privateChannelId"
    case createdAt = "createdAt"
    case creationDay = "creationDay"
    case deletedAt = "deletedAt"
    case identifier = "identifier"
    case message = "message"
    case type = "type"
    case updatedAt = "updatedAt"
    case privateAuthorId = "privateAuthorId"
}

public enum PostRelationships: String {
    case author = "author"
    case channel = "channel"
    case files = "files"
}


// MARK: - Path Pattern
extension Post: PathPattern {
    static func nextPagePathPattern() -> String {
        return "teams/:team.identifier/channels/:identifier/posts/:lastPostId/before/:page/:size"
    }
    static func firstPagePathPattern() -> String {
        return "teams/:team.identifier/channels/:identifier/posts/page/:page/:size"
    }
    static func updatePathPattern() -> String {
        return "teams/:\(teamIdentifierPath())/posts/:\(PostAttributes.identifier)"
    }
    static func creationPathPattern() -> String {
        return "teams/:\(teamIdentifierPath())/channels/:\(channelIdentifierPath())/posts/create"
    }
}

// MARK: - Mapping
extension Post: Mapping {
    class func creationMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingsFromDictionary([
            "id" : PostAttributes.identifier.rawValue,
            "pending_post_id" : PostAttributes.privatePendingId.rawValue
            ])
        return mapping
    }
    class func listMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.forceCollectionMapping = true
        mapping.assignsNilForMissingRelationships = false
        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(PostAttributes.identifier.rawValue)
        mapping.addAttributeMappingsFromDictionary([
            "(\(PostAttributes.identifier)).create_at" : PostAttributes.createdAt.rawValue,
            "(\(PostAttributes.identifier)).update_at" : PostAttributes.updatedAt.rawValue,
            "(\(PostAttributes.identifier)).message" : PostAttributes.message.rawValue,
            "(\(PostAttributes.identifier)).type" : PostAttributes.type.rawValue,
            "(\(PostAttributes.identifier)).user_id" : PostAttributes.privateAuthorId.rawValue,
            "(\(PostAttributes.identifier)).channel_id" : PostAttributes.privateChannelId.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).filenames",
            toKeyPath: PostRelationships.files.rawValue,
            withMapping: File.mapping()))
        return mapping
    }
}

// MARK: - Request Mapping
extension Post: RequestMapping {
    class func creationRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromDictionary([
            filesLinkPath() : "filenames",
            PostAttributes.privateChannelId.rawValue : "channel_id",
            PostAttributes.privatePendingId.rawValue : "pending_post_id"
            ])
        return mapping
    }

}

extension Post {

    func timeIntervalSincePost(post: Post!) -> NSTimeInterval {
        return createdAt!.timeIntervalSinceDate(post.createdAt!)
    }
    func hasAttachments() -> Bool {
        return files.count > 0
    }
}

//  MARK: - Support
extension Post: Support {
    class func filesLinkPath() -> String {
        return PostRelationships.files.rawValue + "." + FileAttributes.privateLink.rawValue
    }
    class func channelIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelAttributes.identifier)"
    }
    class func teamIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelRelationships.team).\(TeamAttributes.identifier)"
    }
    
    private func computeDisplayDay() {
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day]
        let calendar = NSCalendar.sharedGregorianCalendar
        let components = calendar.components(unitFlags, fromDate: createdAt!)
        self.creationDay = calendar.dateFromComponents(components)
    }
    private func computePendingId() {
        self.privatePendingId = "\(Preferences.sharedInstance.currentUserId):\(self.createdAt!.timeIntervalSince1970)"
    }
    private func computeCreatedAtString() {
        self.createdAtString = self.createdAt!.messageTimeFormat()
    }
    private func computeCreatedAtStringWidth() {
        self.createdAtStringWidth = StringUtils.widthOfString(self.createdAtString, font: UIFont.systemFontOfSize(12))
    }
    private func computeAttributedString() {
        self.attributedMessage = TSMarkdownParser.sharedInstance.attributedStringFromMarkdown(self.message!)
    }
    private func computeAttributedMessageHeight() {
        self.attributedMessageHeight = StringUtils.heightOfAttributedString(self.attributedMessage)
    }
}