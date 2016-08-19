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

final class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    let queue = dispatch_group_create()
    
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void) {
        let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = NSDate()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        self.configureBackendPendingId(postToSend)
        
        RealmUtils.save(postToSend)
        
        Api.sharedInstance.sendPost(postToSend) { (error) in
            completion(error: error)
        }
    }
    
    private func configureBackendPendingId(post: Post) {
        let id = (DataManager.sharedInstance.currentUser?.identifier)!
        let time = "\((post.createdAt?.timeIntervalSince1970)!)"
        post.pendingId = "\(id):\(time)"
    }
    
    private func uploadAttachmentsIfNeeded(attachments: Array<UIImage>, completion: (finished: Bool, error: Error?) -> Void) {
        for attachment in attachments {
            dispatch_group_enter(self.queue)
            Api.sharedInstance.uploadFile({ (file, error) in
                print("z_Z")
                }, progress: { (progressValue, index) in
                    print("z_Z")
            })
        }
    }
}