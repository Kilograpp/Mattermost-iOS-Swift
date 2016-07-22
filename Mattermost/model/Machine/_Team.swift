// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Team.swift instead.

import Foundation
import CoreData

public enum TeamAttributes: String {
    case displayName = "displayName"
    case identifier = "identifier"
    case name = "name"
}

public enum TeamRelationships: String {
    case channels = "channels"
}

public class _Team: ManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Team"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Team.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var displayName: String?

    @NSManaged public
    var identifier: String?

    @NSManaged public
    var name: String?

    // MARK: - Relationships

    @NSManaged public
    var channels: NSSet

}

extension _Team {

    func addChannels(objects: NSSet) {
        let mutable = self.channels.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.channels = mutable.copy() as! NSSet
    }

    func removeChannels(objects: NSSet) {
        let mutable = self.channels.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.channels = mutable.copy() as! NSSet
    }

    func addChannelsObject(value: Channel) {
        let mutable = self.channels.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.channels = mutable.copy() as! NSSet
    }

    func removeChannelsObject(value: Channel) {
        let mutable = self.channels.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.channels = mutable.copy() as! NSSet
    }

}

