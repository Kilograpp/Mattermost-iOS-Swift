//
//  PostUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void) {
        let postToSend = Post()
        postToSend.message = message
        postToSend.createdAt = NSDate()
        postToSend.channel = channel
        
        RealmUtils.save(postToSend)
        
        let realm = try! Realm()
        try! realm.write() {
            postToSend.channel = channel
            postToSend.privateChannelId = channel.identifier
        }
        
        completion(error: nil)
    }
}