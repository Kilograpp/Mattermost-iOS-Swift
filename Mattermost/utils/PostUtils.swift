//
//  PostUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    
    func sentPostForChannel(with channel: Channel, message: String, realm: Realm, attachments: NSArray?, completion: (error: Error?) -> Void) {
        
//        realm.beginWrite()
        
//        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            
//        }
//
        let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = NSDate()
//        postToSend.channel = channel
//        postToSend.privateChannelId = channel.identifier
        //FIXME: fixme asap
        postToSend.identifier = message
        
//        RealmUtils.save(postToSend)
        
        
        
        try! realm.write({ 
            realm.add(postToSend, update: false);
            postToSend.privateChannelId = channel.identifier
        })
    
//        RLMRealmDidChangeNotification
//        [[RBQRealmChangeLogger de] didChangeObject:self];
        
//        try! realm.commitWrite()
        
        completion(error: nil)
    }
}