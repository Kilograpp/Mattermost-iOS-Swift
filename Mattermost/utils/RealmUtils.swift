//
//  RealmUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 21/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmUtils {
    
    private static var realmForMainThread: Realm = {
        return try! Realm()
    }()
   
    static func realmForCurrentThread() -> Realm {
        if NSThread.isMainThread() {
            return realmForMainThread
        }
        return try! Realm()
    }
    
    static func save(objects: [RealmObject]) {
        let realm = realmForCurrentThread()
        
        try! realm.write({
            realm.add(objects, update: true)
        })
    }
    
    static func save(object: RealmObject) {
        let realm = realmForCurrentThread()
        
        try! realm.write({
            realm.add(object, update: true)
        })
    }
}