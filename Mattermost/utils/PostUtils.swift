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
    func sendReplyToPost(post: Post, channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void)
    func updateSinglePost(post: Post, message: String, attachments: NSArray?, completion: (error: Error?) -> Void)
    func deletePost(post: Post, completion: (error: Error?) -> Void)
    func uploadImages(channel: Channel, images: Array<AssignedPhotoViewItem>, completion: (finished: Bool, error: Error?) -> Void,  progress:(value: Float, index: Int) -> Void)
    func cancelImageItemUploading(item: AssignedPhotoViewItem)
}

private protocol Private : class {
//    func assignFilesToPost(post: Post)
    func assignFilesToPostIfNeeded(post: Post)
    func clearUploadedAttachments()
}

final class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    private let upload_images_group = dispatch_group_create()
    private var images: Array<AssignedPhotoViewItem>?
    
    private var test: File?
    
    private func configureBackendPendingId(post: Post) {
        let id = (DataManager.sharedInstance.currentUser?.identifier)!
        let time = "\((post.createdAt?.timeIntervalSince1970)!)"
        post.pendingId = "\(id):\(time)"
    }
    
    private var assignedFiles: Array<File> = Array()
}

extension PostUtils : Public {
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void) {
        let postToSend = Post()
        
//        RealmUtils.save(self.assignedFiles)
        postToSend.message = message
        postToSend.createdAt = NSDate()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)
        
        Api.sharedInstance.sendPost(postToSend) { (error) in
            completion(error: error)
            self.clearUploadedAttachments()
        }
    }
    
    func sendReplyToPost(post: Post, channel: Channel, message: String, attachments: NSArray?, completion: (error: Error?) -> Void) {
        let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = NSDate()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        postToSend.parentId = post.identifier
        postToSend.rootId = post.identifier
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)
        RealmUtils.save(postToSend)
        
        Api.sharedInstance.sendPost(postToSend) { (error) in
            completion(error: error)
            self.clearUploadedAttachments()
        }
    }

    func updateSinglePost(post: Post, message: String, attachments: NSArray?, completion: (error: Error?) -> Void) {
        print("updatePost")
        try! RealmUtils.realmForCurrentThread().write({
          //  post.message = message
          //  post.updatedAt = NSDate()
          //  self.configureBackendPendingId(post)
          //  self.assignFilesToPostIfNeeded(post)
            
            post.message = message
            post.updatedAt = NSDate()
            self.configureBackendPendingId(post)
            self.assignFilesToPostIfNeeded(post)
            
        })
        /*  let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = post.createdAt
        postToSend.identifier = post.identifier
        postToSend.channelId = post.channel.identifier
        postToSend.updatedAt = NSDate()
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)*/
        
        Api.sharedInstance.updateSinglePost(post) { (error) in
            print("yeap")
            if (error != nil) {
                print(error?.message)
            }
        }
    }
    
    func deletePost(post: Post, completion: (error: Error?) -> Void) {
        Api.sharedInstance.deletePost(post) { (error) in
            print("deleted")
        }
    }
    
    func uploadImages(channel: Channel, images: Array<AssignedPhotoViewItem>, completion: (finished: Bool, error: Error?) -> Void, progress:(value: Float, index: Int) -> Void) {
        self.images = images
        for item in self.images! {
            if !item.uploaded {
                dispatch_group_enter(self.upload_images_group)
                item.uploading = true
                Api.sharedInstance.uploadImageItemAtChannel(item, channel: channel, completion: { (file, error) in
                    completion(finished: false, error: error)
                    if self.assignedFiles.count == 0 {
                        self.test = file
                    }
                    self.assignedFiles.append(file!)
                    dispatch_group_leave(self.upload_images_group)
                    }, progress: { (identifier, value) in
                        let index = self.images!.indexOf({$0.identifier == identifier})
                        guard (index != nil) else {
                            return
                        }
                        progress(value: value, index: index!)
                })
            }
            
            dispatch_group_notify(self.upload_images_group, dispatch_get_main_queue(), {
                //FIXME: add error
                completion(finished: true, error: nil)
            })
        }
    }
    
//    func assignFilesToPost(post: Post) {
//        post.files = List(self.assignedFiles)
//    }
    
    func cancelImageItemUploading(item: AssignedPhotoViewItem) {
        Api.sharedInstance.cancelUploadingOperationForImageItem(item)
        self.images?.removeObject(item)
    }
}

extension PostUtils : Private {
    private func assignFilesToPostIfNeeded(post: Post) {
        if self.assignedFiles.count > 0 {
            post.files.appendContentsOf(self.assignedFiles)
        }
    }
    
    func clearUploadedAttachments() {
        self.assignedFiles.removeAll()
        self.images?.removeAll()
    }
}