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

private protocol Public : class {
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void)
    func uploadImages(channel: Channel, images: Array<UIImage>, completion: (finished: Bool, error: Error?) -> Void,  progress:(value: Float, index: Int) -> Void)
    func assignImagesToPost(post: Post,images: Array<UIImage>)
}

final class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    private let upload_images_group = dispatch_group_create()
    
    
    private func configureBackendPendingId(post: Post) {
        let id = (DataManager.sharedInstance.currentUser?.identifier)!
        let time = "\((post.createdAt?.timeIntervalSince1970)!)"
        post.pendingId = "\(id):\(time)"
    }
}

extension PostUtils : Public {
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

    func uploadImages(channel: Channel, images: Array<UIImage>, completion: (finished: Bool, error: Error?) -> Void, progress:(value: Float, index: Int) -> Void) {
        for image in images {
            dispatch_group_enter(self.upload_images_group)
            Api.sharedInstance.uploadImageAtChannel(image, channel: channel, completion: { (file, error) in
                completion(finished: false, error: error)
                dispatch_group_leave(self.upload_images_group)
                }, progress: { (value) in
                    let indexOfImage = Int(images.indexOf(image)!)
                    progress(value: value, index: indexOfImage)
            })
            
            dispatch_group_notify(self.upload_images_group, dispatch_get_main_queue(), {
                //FIXME: add error
                completion(finished: true, error: nil)
            })
        }
    }
    
    func assignImagesToPost(post: Post,images: Array<UIImage>) {
        
    }
}