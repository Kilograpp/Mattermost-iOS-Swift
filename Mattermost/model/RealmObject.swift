//
//  RealmObject.swift
//  Mattermost
//
//  Created by Maxim Gubin on 20/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class RealmObject: Object {

}

public enum CommonAttributes: String {
    case identifier = "identifier"
    case username = "username"
    
}

protocol CommonFinders {
    static func objectById(id: String) -> Self?
    static func objectByUsername(username: String) -> Self?
}

protocol CommonMappings {
    static func mapping() -> RKObjectMapping
    static func emptyResponseMapping() -> RKObjectMapping
    static func emptyMapping() -> RKObjectMapping
    static func requestMapping() -> RKObjectMapping
}

// MARK: - Mappings
extension RealmObject: CommonMappings  {
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary(["id" : CommonAttributes.identifier.rawValue])
        return mapping;
    }
    
    class func emptyResponseMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: NSNull.self)
    }
    
    class func emptyMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: self)
    }
    
    class func requestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromDictionary([CommonAttributes.identifier.rawValue : "id"])
        return mapping;
    }
}
//
//// MARK: - Finders
extension RealmObject : CommonFinders {
    class func objectById(id: String) -> Self? {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(self, key: id);
        
    }
    
    class func objectByUsername(username: String) -> Self? {
        let realm = try! Realm()
        return realm.objects(self).filter(CommonAttributes.username.rawValue + " == " + username).first;
    }
}