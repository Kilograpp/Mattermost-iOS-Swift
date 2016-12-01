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


private protocol Inteface {
    func hasAttachments() -> Bool
    func hasSameAuthor(_ post: Post!) -> Bool
    func timeIntervalSincePost(_ post: Post!) -> TimeInterval
    func hasParentPost() -> Bool
    func parentPost() -> Post?
    func permalink() -> String
}

private protocol Delegate {
    func onStatusChange(_ handler: ((_ status: PostStatus) -> Void)?)
}

enum PostAttributes: String {
    case authorId = "authorId"
    case channelId = "channelId"
    case pendingId = "pendingId"
    case createdAt = "createdAt"
    case parentId = "parentId"
    case rootId = "rootId"
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
    case localId = "localIdentifier"
}

enum PostRelationships: String {
    case author = "author"
    case channel = "channel"
    case files = "files"
    case attachments = "attachments"
    case day = "day"
}


@objc enum PostStatus: Int {
    case `default` = 0
    case error = -1
    case sending = 1
}

@objc enum MessageType: Int {
    case `default`
    case slackAttachment
    case system
}

@objc enum CellType: Int {
    case attachment
    case followUp
    case common
}


final class Post: RealmObject {
    fileprivate dynamic var _attributedMessageData: RealmAttributedString?
    dynamic var messageType: MessageType = .default
    dynamic var cellType: CellType = .common
    dynamic var channelId: String?
    dynamic var authorId: String?
    dynamic var pendingId: String?
    dynamic var parentId: String?
    dynamic var rootId: String?
    dynamic var createdAt: Date?
    dynamic var createdAtString: String?
    dynamic var createdAtStringWidth: Float = 0.0
    dynamic var updatedAt: Date?
    dynamic var deletedAt: Date?
    dynamic var status: PostStatus = .default
    dynamic var localIdentifier: String?

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
    
    func setType(_ type: String) {
        switch type {
            case _ where type.hasPrefix("system"):
                self.messageType = .system
                self.authorId = Constants.Realm.SystemUserIdentifier
            case "slack_attachment":
                self.messageType = .slackAttachment
            default: break
        }
        
    }
    
    var author: User! {
        return safeRealm.object(ofType: User.self, forPrimaryKey: self.authorId as AnyObject)
    }
    var channel: Channel! {
        return safeRealm.object(ofType: Channel.self, forPrimaryKey: self.channelId as AnyObject)
    }
    
    let files = List<File>()
    let attachments = List<Attachment>()
    
    dynamic var day: Day?
    fileprivate var hasObserverAttached: Bool = false
    fileprivate var statusChangeHandler: ((_ status: PostStatus) -> Void)?
    

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
        return PostAttributes.localId.rawValue
    }
    
    override class func indexedProperties() -> [String] {
        return [PostAttributes.createdAt.rawValue, PostAttributes.identifier.rawValue, PostAttributes.localId.rawValue]
    }
    
}

private protocol Computations: class {
    func resetStatus()
    func computeLocalIdentifier()
    func computeDay()
    func computePendingId()
    func computeCreatedAtString()
    func computeMissingFields()
    func computeCreatedAtStringWidth()
    func computeAttributedString()
    func computeAttributedStringData()
    func computeAttributedMessageHeight()
    func computeCellType()
    func setSystemAuthorIfNeeded()
}

private protocol Support: class {
    static func filesLinkPath() -> String
    static func teamIdentifierPath() -> String
    static func channelIdentifierPath() -> String
}

private protocol KVO: class {
    func addStatusObserverIfNeeded()
    func removeStatusObserverIfNeeded()
    func notifyStatusObserverIfNeeded(_ oldStatus: PostStatus)
}

//  MARK: - Support
extension Post: Support {
    static func filesLinkPath() -> String {
        return PostRelationships.files.rawValue + "." + FileAttributes.rawLink.rawValue
    }
    static func channelIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelAttributes.identifier)"
    }
    static func teamIdentifierPath() -> String {
        return "\(PostRelationships.channel).\(ChannelRelationships.team).\(TeamAttributes.identifier)"
    }
}

// MARK: - Inteface
extension Post: Inteface {
    func hasAttachments() -> Bool {
        return self.files.count != 0
    }
    func hasSameAuthor(_ post: Post!) -> Bool {
        return self.authorId == post.authorId
    }
    func timeIntervalSincePost(_ post: Post!) -> TimeInterval {
        return createdAt!.timeIntervalSince(post.createdAt!)
    }
    func hasParentPost() -> Bool {
        return (self.parentId != "" && self.parentId != nil)
//        return self.parentId != nil
    }
    
    func parentPost() -> Post? {
        //temp!!! will be a post instead of parent post
//        return (self.parentId != nil) ? try! Realm().objects(Post).filter("identifier = %@", self.parentId!).last : nil
        if let parentPost = try! Realm().objects(Post.self).filter("identifier = %@", self.parentId!).last {
                return parentPost
        }
        return self
    }
    
    func permalink() -> String {
        return Preferences.sharedInstance.serverUrl! + "/" + (DataManager.sharedInstance.currentTeam?.name!)! + "/pl/" + self.identifier!
    }
}

// MARK: - Delegate
extension Post: Delegate {
    func onStatusChange(_ handler: ((_ status: PostStatus) -> Void)?) {
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
    func computeCellType() {
        if self.hasAttachments() {
            self.cellType = .attachment
        }
    }
    fileprivate func computeDay() {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .day]
        let calendar = Calendar.sharedGregorianCalendar
        let components = calendar!.dateComponents(unitFlags, from: createdAt!)
        let dayDate = calendar!.date(from: components)
        let key = "\(dayDate!.timeIntervalSince1970)_\(channelId!)"
        var day: Day! = RealmUtils.realmForCurrentThread().object(ofType: Day.self, forPrimaryKey: key)

        defer { self.day = day }
        guard day == nil else { return }
        
        day = Day()
        day.date = dayDate
        day.key = key
        day.channelId = channelId
        
    }
    fileprivate func computePendingId() {
        self.pendingId = "\(Preferences.sharedInstance.currentUserId):\(self.createdAt!.timeIntervalSince1970)"
    }
    fileprivate func computeCreatedAtString() {
        self.createdAtString = self.createdAt!.messageTimeFormat()
    }
    fileprivate func computeCreatedAtStringWidth() {
        self.createdAtStringWidth = StringUtils.widthOfString(self.createdAtString as NSString!, font: FontBucket.postDateFont)
    }
    fileprivate func computeAttributedString() {
        self.attributedMessage = NSTextStorage(attributedString: TSMarkdownParser.sharedInstance.attributedString(fromMarkdown: self.message!))
    }
    fileprivate func computeAttributedStringData() {
        self._attributedMessageData = RealmAttributedString(attributedString: self.attributedMessage)
    }
    fileprivate func computeAttributedMessageHeight() {
        self.attributedMessageHeight = StringUtils.heightOfAttributedString(self.attributedMessage)
    }
    fileprivate func computeLocalIdentifier() {
        guard localIdentifier == nil else { return }
        //s3 refactor
//        let dateString = createdAt!.dateFormatForPostKey()
//         self.localIdentifier = channelId! + authorId! + dateString
        self.localIdentifier = "\(StringUtils.randomUUID())-\(self.createdAt?.timeIntervalSince1970)"
    }

    func setSystemAuthorIfNeeded() {
        guard self.messageType == .system else { return }
        self.authorId = Constants.Realm.SystemUserIdentifier
    }
    fileprivate func resetStatus() {
        self.status = .default
    }

    func computeMissingFields() {
        computeAttributedString()
        computeAttributedStringData()
        computeAttributedMessageHeight()
        computeCreatedAtString()
        computeCreatedAtStringWidth()
        computeDay()
        computeCellType()
        computeLocalIdentifier()
    }
}

// MARK: - KVO
extension Post: KVO {
    fileprivate func notifyStatusObserverIfNeeded(_ oldStatus: PostStatus) {
        if oldStatus != self.status {
            self.statusChangeHandler?(self.status)
        }
    }
    func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        let oldKey = change![NSKeyValueChangeKey.oldKey.rawValue]
        let status = PostStatus(rawValue: oldKey as! Int)
        notifyStatusObserverIfNeeded(status!)
    }
    fileprivate func addStatusObserverIfNeeded() {
        if !self.hasObserverAttached {
            self.addObserver(self, forKeyPath: PostAttributes.status.rawValue, options: .old, context: nil)
            self.hasObserverAttached = true
        }
    }
    
    fileprivate func removeStatusObserverIfNeeded() {
        if self.hasObserverAttached {
            self.removeObserver(self, forKeyPath: PostAttributes.status.rawValue)
            self.hasObserverAttached = false
        }
    }
}
