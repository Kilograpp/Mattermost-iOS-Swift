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
    static func objectById(_ id: String) -> Self?
    static func objectByUsername(_ username: String) -> Self?
    
}

// MARK: - Finders
extension RealmObject : CommonFinders {
    static func objectById(_ id: String) -> Self? {
        let realm = try! Realm()
        return realm.object(ofType: self, forPrimaryKey: id as AnyObject);
        
    }
    
    static func objectByUsername(_ username: String) -> Self? {
        let realm = try! Realm()
        return realm.objects(self).filter(CommonAttributes.username.rawValue + " == " + username).first;
    }
}
