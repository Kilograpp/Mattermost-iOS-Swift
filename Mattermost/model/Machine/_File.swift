// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to File.swift instead.

import Foundation
import CoreData

public enum FileAttributes: String {
    case backendLink = "backendLink"
    case backendMimeType = "backendMimeType"
    case fileExtension = "fileExtension"
    case hasPreviewImage = "hasPreviewImage"
    case localLink = "localLink"
    case name = "name"
    case size = "size"
}

public enum FileRelationships: String {
    case post = "post"
}

public class _File: ManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "File"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _File.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var backendLink: String?

    @NSManaged public
    var backendMimeType: String?

    @NSManaged public
    var fileExtension: String?

    @NSManaged public
    var hasPreviewImage: NSNumber?

    @NSManaged public
    var localLink: String?

    @NSManaged public
    var name: String?

    @NSManaged public
    var size: NSNumber?

    // MARK: - Relationships

    @NSManaged public
    var post: Post?

}

