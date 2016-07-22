// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import Foundation
import CoreData

public enum PostAttributes: String {
    case backendPendingId = "backendPendingId"
    case channelId = "channelId"
    case createdAt = "createdAt"
    case creationDay = "creationDay"
    case deletedAt = "deletedAt"
    case identifier = "identifier"
    case message = "message"
    case type = "type"
    case updatedAt = "updatedAt"
    case userId = "userId"
}

public enum PostRelationships: String {
    case author = "author"
    case channel = "channel"
    case files = "files"
}

public class _Post: ManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Post"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Post.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var backendPendingId: String?

    @NSManaged public
    var channelId: String?

    @NSManaged public
    var createdAt: NSDate?

    @NSManaged public
    var creationDay: NSDate?

    @NSManaged public
    var deletedAt: NSDate?

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var message: String?

    @NSManaged public
    var type: String?

    @NSManaged public
    var updatedAt: NSDate?

    @NSManaged public
    var userId: String?

    // MARK: - Relationships

    @NSManaged public
    var author: User?

    @NSManaged public
    var channel: Channel?

    @NSManaged public
    var files: NSSet

}

extension _Post {

    func addFiles(objects: NSSet) {
        let mutable = self.files.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.files = mutable.copy() as! NSSet
    }

    func removeFiles(objects: NSSet) {
        let mutable = self.files.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.files = mutable.copy() as! NSSet
    }

    func addFilesObject(value: File) {
        let mutable = self.files.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.files = mutable.copy() as! NSSet
    }

    func removeFilesObject(value: File) {
        let mutable = self.files.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.files = mutable.copy() as! NSSet
    }

}

