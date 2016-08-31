//
//  Post.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import RestKit
import TSMarkdownParser


private protocol Inteface {
    func hasAttachments() -> Bool
    func hasSameAuthor(post: Post!) -> Bool
    func timeIntervalSincePost(post: Post!) -> NSTimeInterval
}

private protocol Delegate {
    func onStatusChange(handler: ((status: PostStatus) -> Void)?)
}

enum PostAttributes: String {
    case authorId = "authorId"
    case channelId = "channelId"
    case pendingId = "pendingId"
    case createdAt = "createdAt"
    case creationDay = "creationDay"
    case deletedAt = "deletedAt"
    case identifier = "identifier"
    case message = "message"
    case type = "type"
    case status = "status"
    case updatedAt = "updatedAt"
    case attributedMessage = "attributedMessage"
    case attributedMessageHeight = "attributedMessageHeight"
    case hasObserverAttached = "hasObserverAttached"
}

enum PostRelationships: String {
    case author = "author"
    case channel = "channel"
    case files = "files"
    case attachments = "attachments"
    case day = "day"
}


@objc enum PostStatus: Int {
    case Default = 0
    case Error = -1
    case Sending = 1
}

@objc enum MessageType: Int {
    case Default
    case SlackAttachment
    case System
}

@objc enum CellType: Int {
    case Attachment
    case FollowUp
    case Common
}


final class Post: RealmObject {
    private dynamic var _attributedMessageData: RealmAttributedString?
    dynamic var messageType: MessageType = .Default
    dynamic var cellType: CellType = .Common
    dynamic var channelId: String?
    dynamic var authorId: String?
    dynamic var pendingId: String?
    dynamic var createdAt: NSDate?
    dynamic var createdAtString: String?
    dynamic var createdAtStringWidth: Float = 0.0
    dynamic var updatedAt: NSDate?
    dynamic var deletedAt: NSDate?
    dynamic var status: PostStatus = .Default
    dynamic var identifier: String? {
        didSet {
            resetStatus()
        }
    }
    dynamic var message: String?
    lazy var attributedMessage: NSTextStorage? = {
        let string = self._attributedMessageData?.attributedString
        return string
    }()
    dynamic var attributedMessageHeight: Float = 0.0
    
    func setType(type: String) {
        switch type {
            case _ where type.hasPrefix("system"):
                self.messageType = .System
                self.authorId = Constants.Realm.SystemUserIdentifier
            case "slack_attachment":
                self.messageType = .SlackAttachment
            default: break
        }
        
    }
    
    var author: User! {
        return safeRealm.objectForPrimaryKey(User.self, key: self.authorId)
    }
    var channel: Channel! {
        return safeRealm.objectForPrimaryKey(Channel.self, key: self.channelId)
    }
    
    let files = List<File>()
    let attachments = List<Attachment>()
    
    dynamic var day: Day?
    private var hasObserverAttached: Bool = false
    private var statusChangeHandler: ((status: PostStatus) -> Void)?
    

    deinit {
        self.removeStatusObserverIfNeeded()
    }
    
    override class func ignoredProperties() -> [String] {
        return [PostAttributes.attributedMessage.rawValue,
                PostRelationships.author.rawValue,
                PostRelationships.channel.rawValue,
                PostAttributes.hasObserverAttached.rawValue
        ]
    }
    
    override class func primaryKey() -> String {
        return PostAttributes.identifier.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [PostAttributes.createdAt.rawValue, PostAttributes.identifier.rawValue]
    }
    
}

private protocol PathPattern: class {
    static func updatePathPattern() -> String
    static func nextPagePathPattern() -> String
    static func creationPathPattern() -> String
    static func firstPagePathPattern() -> String
}

private protocol ResponseMapping: class {
    static func listMapping() -> RKObjectMapping
    static func creationMapping() -> RKObjectMapping
}

private protocol RequestMapping: class {
    static func creationRequestMapping() -> RKObjectMapping
}

private protocol ResponseDescriptor: class {
    static func updateResponseDescriptor() -> RKResponseDescriptor
    static func nextPageResponseDescriptor() -> RKResponseDescriptor
    static func firstPageResponseDescriptor() -> RKResponseDescriptor
}

private protocol Computations: class {
    func resetStatus()
    func computeDay()
    func computePendingId()
    func computeCreatedAtString()
    func computeMissingFields()
    func computeCreatedAtStringWidth()
    func computeAttributedString()
    func computeAttributedStringData()
    func computeAttributedMessageHeight()
    func setSystemAuthorIfNeeded()
}

private protocol RequestDescriptor : class {
    static func creationRequestDescriptor() -> RKRequestDescriptor
}

private protocol Support: class {
    static func filesLinkPath() -> String
    static func teamIdentifierPath() -> String
    static func channelIdentifierPath() -> String
}

private protocol KVO: class {
    func addStatusObserverIfNeeded()
    func removeStatusObserverIfNeeded()
    func notifyStatusObserverIfNeeded(oldStatus: PostStatus)
}


// MARK: - Path Patterns
extension Post: PathPattern {
    static func nextPagePathPattern() -> String {
        return "teams/:\(PageWrapper.teamIdPath())/" +
               "channels/:\(PageWrapper.channelIdPath())/" +
               "posts/:\(PageWrapper.lastPostIdPath())/" +
               "before/:\(PageWrapper.pagePath())/:\(PageWrapper.sizePath())"
    }
    static func firstPagePathPattern() -> String {
        return "teams/:\(PageWrapper.teamIdPath())/" +
               "channels/:\(PageWrapper.channelIdPath())/" +
               "posts/page/:\(PageWrapper.pagePath())/:\(PageWrapper.sizePath())"
    }
    static func updatePathPattern() -> String {
        return "teams/:\(self.teamIdentifierPath())/posts/:\(PostAttributes.identifier)"
    }
    static func creationPathPattern() -> String {
        return "teams/:\(self.teamIdentifierPath())/channels/:\(self.channelIdentifierPath())/posts/create"
    }
}

// MARK: - Mapping
extension Post: ResponseMapping {
    class func creationMapping() -> RKObjectMapping {
        let mapping = super.emptyMapping()
        mapping.addAttributeMappingsFromDictionary([
            "id"                : PostAttributes.identifier.rawValue,
            "pending_post_id"   : PostAttributes.pendingId.rawValue,
            "message"           : PostAttributes.message.rawValue,
            "create_at"         : PostAttributes.createdAt.rawValue,
            "update_at"         : PostAttributes.updatedAt.rawValue,
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
            "(\(PostAttributes.identifier)).user_id" : PostAttributes.authorId.rawValue,
            "(\(PostAttributes.identifier)).channel_id" : PostAttributes.channelId.rawValue
            ])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).filenames",
                                                           toKeyPath: PostRelationships.files.rawValue,
                                                         withMapping: File.simplifiedMapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "(\(PostAttributes.identifier)).props.attachments",
                                                           toKeyPath: PostRelationships.attachments.rawValue,
                                                         withMapping: Attachment.mapping()))
        return mapping
    }
}


//  MARK: - Support
extension Post: Support {
    private static func filesLinkPath() -> String {
        return PostRelationships.files.rawValue + "." + FileAttributes.rawLink.rawValue
    }
    private static func channelIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelAttributes.identifier)"
    }
    private static func teamIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelRelationships.team).\(TeamAttributes.identifier)"
    }
}

// MARK: - Inteface
extension Post: Inteface {
    func hasAttachments() -> Bool {
        return self.files.count != 0
    }
    func hasSameAuthor(post: Post!) -> Bool {
        return self.authorId == post.authorId
    }
    func timeIntervalSincePost(post: Post!) -> NSTimeInterval {
        return createdAt!.timeIntervalSinceDate(post.createdAt!)
    }

}

// MARK: - Delegate
extension Post: Delegate {
    func onStatusChange(handler: ((status: PostStatus) -> Void)?) {
        if handler == nil {
            self.removeStatusObserverIfNeeded()
        } else {
            self.addStatusObserverIfNeeded()
        }
        
        self.statusChangeHandler = handler
    }
}

// MARK: - Computations
extension Post: Computations {
    
    private func computeDay() {
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day]
        let calendar = NSCalendar.sharedGregorianCalendar
        let components = calendar.components(unitFlags, fromDate: createdAt!)
        let dayDate = calendar.dateFromComponents(components)
        let key = "\(dayDate!.timeIntervalSince1970)_\(self.channel.identifier!)"
        var day: Day! = RealmUtils.realmForCurrentThread().objectForPrimaryKey(Day.self, key: key)

        defer { self.day = day }
        guard day == nil else { return }
        
        day = Day()
        day.date = dayDate
        day.key = key
        day.channelId = channelId
        
    }
    private func computePendingId() {
        self.pendingId = "\(Preferences.sharedInstance.currentUserId):\(self.createdAt!.timeIntervalSince1970)"
    }
    private func computeCreatedAtString() {
        self.createdAtString = self.createdAt!.messageTimeFormat()
    }
    private func computeCreatedAtStringWidth() {
        self.createdAtStringWidth = StringUtils.widthOfString(self.createdAtString, font: FontBucket.postDateFont)
    }
    private func computeAttributedString() {
        self.attributedMessage = NSTextStorage(attributedString: TSMarkdownParser.sharedInstance.attributedStringFromMarkdown(self.message!))
    }
    private func computeAttributedStringData() {
        self._attributedMessageData = RealmAttributedString(attributedString: self.attributedMessage)
    }
    private func computeAttributedMessageHeight() {
        self.attributedMessageHeight = StringUtils.heightOfAttributedString(self.attributedMessage)
    }

    func setSystemAuthorIfNeeded() {
        guard self.messageType == .System else { return }
        self.authorId = Constants.Realm.SystemUserIdentifier
    }
    private func resetStatus() {
        self.status = .Default
    }
    

    func computeMissingFields() {
        self.computeAttributedString()
        self.computeAttributedStringData()
        self.computeAttributedMessageHeight()
        self.computeCreatedAtString()
        self.computeCreatedAtStringWidth()
        self.computeDay()
    }
}

// MARK: - KVO
extension Post: KVO {
    private func notifyStatusObserverIfNeeded(oldStatus: PostStatus) {
        if oldStatus != self.status {
            self.statusChangeHandler?(status: self.status)
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        notifyStatusObserverIfNeeded(PostStatus(rawValue: change![NSKeyValueChangeOldKey]! as! Int)!)
    }
    private func addStatusObserverIfNeeded() {
        if !self.hasObserverAttached {
            self.addObserver(self, forKeyPath: PostAttributes.status.rawValue, options: .Old, context: nil)
            self.hasObserverAttached = true
        }
    }
    
    private func removeStatusObserverIfNeeded() {
        if self.hasObserverAttached {
            self.removeObserver(self, forKeyPath: PostAttributes.status.rawValue)
            self.hasObserverAttached = false
        }
    }
}

// MARK: - Request Mapping
extension Post: RequestMapping {
    static func creationRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromArray([ "message" ])
        mapping.addAttributeMappingsFromDictionary([
            filesLinkPath() : "filenames",
            PostAttributes.channelId.rawValue : "channel_id",
            PostAttributes.pendingId.rawValue : "pending_post_id",
        ])
        return mapping
    }
}

//MARK: - Request Descriptors
extension Post : RequestDescriptor {
    static func creationRequestDescriptor() -> RKRequestDescriptor {
        return RKRequestDescriptor(mapping: creationRequestMapping(), objectClass: Post.self, rootKeyPath: nil, method: .POST)
    }
}


// MARK: - Response Descriptors
extension Post: ResponseDescriptor {
    static func firstPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: listMapping(),
                                    method: .GET,
                                    pathPattern: firstPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: listMapping(),
                                    method: .GET,
                                    pathPattern: updatePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func nextPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: listMapping(),
                                    method: .GET,
                                    pathPattern: nextPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func creationResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: creationMapping(),
                                    method: .POST,
                                    pathPattern: creationPathPattern(),
                                    keyPath: nil,
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
}