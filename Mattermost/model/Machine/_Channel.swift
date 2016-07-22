// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.swift instead.

import Foundation
import CoreData

public enum ChannelAttributes: String {
    case backendType = "backendType"
    case createdAt = "createdAt"
    case displayName = "displayName"
    case firstLoaded = "firstLoaded"
    case header = "header"
    case identifier = "identifier"
    case lastPostDate = "lastPostDate"
    case lastViewDate = "lastViewDate"
    case messagesCount = "messagesCount"
    case name = "name"
    case purpose = "purpose"
    case shouldUpdateAt = "shouldUpdateAt"
    case teamId = "teamId"
    case updatedAt = "updatedAt"
}

public enum ChannelRelationships: String {
    case members = "members"
    case posts = "posts"
    case team = "team"
}

public class _Channel: ManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Channel"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Channel.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var backendType: String?

    @NSManaged public
    var createdAt: NSDate?

    @NSManaged public
    var displayName: String?

    @NSManaged public
    var firstLoaded: NSNumber?

    @NSManaged public
    var header: String?

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var lastPostDate: NSDate?

    @NSManaged public
    var lastViewDate: NSDate?

    @NSManaged public
    var messagesCount: NSNumber?

    @NSManaged public
    var name: String?

    @NSManaged public
    var purpose: String?

    @NSManaged public
    var shouldUpdateAt: NSDate?

    @NSManaged public
    var teamId: String?

    @NSManaged public
    var updatedAt: NSDate?

    // MARK: - Relationships

    @NSManaged public
    var members: NSSet

    @NSManaged public
    var posts: NSSet

    @NSManaged public
    var team: Team?

}

extension _Channel {

    func addMembers(objects: NSSet) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.members = mutable.copy() as! NSSet
    }

    func removeMembers(objects: NSSet) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.members = mutable.copy() as! NSSet
    }

    func addMembersObject(value: User) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.members = mutable.copy() as! NSSet
    }

    func removeMembersObject(value: User) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.members = mutable.copy() as! NSSet
    }

}

extension _Channel {

    func addPosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.posts = mutable.copy() as! NSSet
    }

    func removePosts(objects: NSSet) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.posts = mutable.copy() as! NSSet
    }

    func addPostsObject(value: Post) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.posts = mutable.copy() as! NSSet
    }

    func removePostsObject(value: Post) {
        let mutable = self.posts.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.posts = mutable.copy() as! NSSet
    }

}

