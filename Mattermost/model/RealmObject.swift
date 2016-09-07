//
//  RealmObject.swift
//  Mattermost
//
//  Created by Maxim Gubin on 20/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit
import RealmSwift

class RealmObject: Object {
    final var safeRealm: Realm {
        return realm ?? RealmUtils.realmForCurrentThread()
    }
}

enum CommonAttributes: String {
    case identifier = "identifier"
    case username = "username"
}

protocol CommonFinders: class {
    static func objectById(id: String) -> Self?
    static func objectByUsername(username: String) -> Self?
}
//FIXME: -------------- все что ниже до следующего FIXME убрать!!!
//protocol CommonMappings: class {
//    static func mapping() -> RKObjectMapping
//    static func emptyResponseMapping() -> RKObjectMapping
//    static func emptyMapping() -> RKObjectMapping
//    static func requestMapping() -> RKObjectMapping
//}
//
//// MARK: - Mappings
//extension RealmObject: CommonMappings  {
//    class func mapping() -> RKObjectMapping {
//        let mapping = RKObjectMapping(forClass: self)
//        mapping.addAttributeMappingsFromDictionary(["id" : CommonAttributes.identifier.rawValue])
//        return mapping;
//    }
//    
//    static func emptyResponseMapping() -> RKObjectMapping {
//        return RKObjectMapping(withClass: NSNull.self)
//    }
//    
//    static func emptyMapping() -> RKObjectMapping {
//        return RKObjectMapping(withClass: self)
//    }
//    
//    class func requestMapping() -> RKObjectMapping {
//        let mapping = RKObjectMapping.requestMapping()
//        mapping.addAttributeMappingsFromDictionary([CommonAttributes.identifier.rawValue : "id"])
//        return mapping;
//    }
//}
//FIXME: --------------убрать!!!

// MARK: - Finders
extension RealmObject : CommonFinders {
    static func objectById(id: String) -> Self? {
        let realm = try! Realm()
        return realm.objectForPrimaryKey(self, key: id);
        
    }
    
    static func objectByUsername(username: String) -> Self? {
        let realm = try! Realm()
        return realm.objects(self).filter(CommonAttributes.username.rawValue + " == " + username).first;
    }
}
