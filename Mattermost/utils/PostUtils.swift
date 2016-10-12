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
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func sendExistingPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func resendPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func sendReplyToPost(_ post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updateSinglePost(_ post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func uploadImages(_ channel: Channel, images: Array<AssignedAttachmentViewItem>, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void,  progress:@escaping (_ value: Float, _ index: Int) -> Void)
    func searchTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>, _ error: Error?) -> Void)
    func cancelImageItemUploading(_ item: AssignedAttachmentViewItem)
}

private protocol Private : class {
//    func assignFilesToPost(post: Post)
    func assignFilesToPostIfNeeded(_ post: Post)
    func clearUploadedAttachments()
}

final class PostUtils: NSObject {
    
    static let sharedInstance = PostUtils()
    fileprivate let upload_images_group = DispatchGroup()
    //refactor rename files
    fileprivate var files = Array<AssignedAttachmentViewItem>()
    
    fileprivate var test: File?
    
    fileprivate func configureBackendPendingId(_ post: Post) {
        let id = (DataManager.sharedInstance.currentUser?.identifier)!
        let time = "\((post.createdAt?.timeIntervalSince1970)!)"
        post.pendingId = "\(id):\(time)"
    }
    
    fileprivate var assignedFiles: Array<File> = Array()
}

extension PostUtils : Public {
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let postToSend = Post()
        
//        RealmUtils.save(self.assignedFiles)
        postToSend.message = message
        postToSend.createdAt = Date()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)
        postToSend.computeMissingFields()
        postToSend.status = .sending
        RealmUtils.save(postToSend)
        self.clearUploadedAttachments()
        sendExistingPost(postToSend, completion: completion)
    }
    
    func sendExistingPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        Api.sharedInstance.sendPost(post) { (error) in
            completion(error)
            if error != nil {
                print("error")
                try! RealmUtils.realmForCurrentThread().write({
                    post.status = .error
                })
            }
            
        }
    }
    
    func resendPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        try! RealmUtils.realmForCurrentThread().write({
            post.status = .sending
        })
        sendExistingPost(post, completion: completion)
    }
    
    func sendReplyToPost(_ post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = Date()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        postToSend.parentId = post.identifier
        postToSend.rootId = post.identifier
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)
        postToSend.computeMissingFields()
        RealmUtils.save(postToSend)
        
        Api.sharedInstance.sendPost(postToSend) { (error) in
            completion(error)
            self.clearUploadedAttachments()
        }
    }

    func updateSinglePost(_ post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        try! RealmUtils.realmForCurrentThread().write({
            post.message = message
            post.updatedAt = NSDate() as Date
            self.configureBackendPendingId(post)
            self.assignFilesToPostIfNeeded(post)
            post.computeMissingFields()
        })
    
        Api.sharedInstance.updateSinglePost(post) { (error) in
            completion(error)
        }
    }
    
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        // identifier == nil -> post exists only in database
        let day = post.day
        guard post.identifier != nil else {
            completion(nil)
            return
        }
        Api.sharedInstance.deletePost(post) { (error) in
            completion(error)
            if day?.posts.count == 0 {
                RealmUtils.deleteObject(day!)
            }
        }
    }
    //refactor uploadItemAtChannel
    func uploadFiles(_ channel: Channel,fileItem:AssignedAttachmentViewItem, url:URL, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
            self.files.append(fileItem)
            Api.sharedInstance.uploadFileItemAtChannel(fileItem, url: url, channel: channel, completion: { (file, error) in
                completion(false, error)
                if error != nil {
                    self.files.removeObject(fileItem)
                    return
                }

                self.assignedFiles.append(file!)
                
                print("uploaded")
            }) { (identifier, value) in
                
                let index = self.files.index(where: {$0.identifier == identifier})
                guard (index != nil) else {
                    return
                }
                print("\(index) in progress: \(value)")
                progress(value, index!)
            }
    }
    

    func searchTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>, _ error: Error?) -> Void) {
    Api.sharedInstance.searchPostsWithTerms(terms: terms, channel: channel) { (posts, error) in
    completion(posts!, error)
    }
    }
    
    func uploadImages(_ channel: Channel, images: Array<AssignedAttachmentViewItem>, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
        self.files.append(contentsOf: images)
        for item in files {
            if !item.uploaded && !item.isFile {
                self.upload_images_group.enter()
                item.uploading = true
                Api.sharedInstance.uploadImageItemAtChannel(item, channel: channel, completion: { (file, error) in
                    completion(false, error, item)
                    if error != nil {
                        self.files.removeObject(item)
                        return
                    }
                    
                    if self.assignedFiles.count == 0 {
                        self.test = file
                    }
                    self.assignedFiles.append(file!)
                    self.upload_images_group.leave()
                    }, progress: { (identifier, value) in
                        let index = self.files.index(where: {$0.identifier == identifier})
                        guard (index != nil) else {
                            return
                        }
                        progress(value, index!)
                })
            }
            
            self.upload_images_group.notify(queue: DispatchQueue.main, execute: {
                //FIXME: add error
                completion(true, nil, item)
            })
        }
    }
    
//    func assignFilesToPost(post: Post) {
//        post.files = List(self.assignedFiles)
//    }
    
    func cancelImageItemUploading(_ item: AssignedAttachmentViewItem) {
        Api.sharedInstance.cancelUploadingOperationForImageItem(item)
        if item.uploaded  {
            self.assignedFiles.remove(at: files.index(of: item)!)
        }
        self.files.removeObject(item)
    }
}

extension PostUtils : Private {
    fileprivate func assignFilesToPostIfNeeded(_ post: Post) {
        if self.assignedFiles.count > 0 {
            post.files.append(objectsIn: self.assignedFiles)
        }
    }
    
    func clearUploadedAttachments() {
        self.assignedFiles.removeAll()
        self.files.removeAll()
    }
}
