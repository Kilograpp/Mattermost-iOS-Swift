//
//  RealmUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtils {
   
    static func save(objects: [RealmObject]) {
        let realm = try! Realm()
        
        try! realm.write({
            realm.add(objects, update: true)
        })
    }
    
    static func save(object: RealmObject) {
        let realm = try! Realm()
        
        try! realm.write({
            realm.add(object, update: true)
        })
    }
}