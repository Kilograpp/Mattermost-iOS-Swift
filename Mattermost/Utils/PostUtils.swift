//
//  PostUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift
import Realm

private protocol Interface: class {
    func removeAttachmentAtIdex(_ index: Int)
}

protocol Send: class {
    func sendPost(channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func send(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func resend(post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func reply(post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

protocol Update: class {
    func update(post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

protocol Delete: class {
    func delete(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
}

protocol Search: class {
    func search(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>?, _ error: Error?) -> Void)
}

protocol Upload: class {
    func upload(items: Array<AssignedAttachmentViewItem>, channel: Channel,
                completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void)
    func cancelUpload(item: AssignedAttachmentViewItem)
}


final class PostUtils: NSObject {

//MARK: Properies
    static let sharedInstance = PostUtils()
    fileprivate let upload_files_group = DispatchGroup()
    fileprivate var files = Array<AssignedAttachmentViewItem>()
    
    
    fileprivate var assignedFiles: Array<String> = Array()
}


//MARK: Interface
extension PostUtils: Interface {

    
    func removeAttachmentAtIdex(_ index: Int) {
        if files.indices.contains(index) {
            files.remove(at: index)
        }
        if assignedFiles.indices.contains(index) {
            assignedFiles.remove(at: index)
        }
    }
}


//MARK: Send
extension PostUtils: Send {
    func sendPost(channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let post = postToSend(channel: channel, message: message, attachments: attachments)
        RealmUtils.save(post)
        clearUploadedAttachments()
        send(post: post, completion: completion)
        self.files.forEach { (item) in
            if !item.uploaded { self.cancelUpload(item: item) }
        }
    }
    
    func send(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        Api.sharedInstance.sendPost(post) { (error) in
            if error != nil { try! RealmUtils.realmForCurrentThread().write({ post.status = .error }) }
            completion(error)
        }
    }
    
    func resend(post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        try! RealmUtils.realmForCurrentThread().write({ post.status = .sending })
        send(post: post, completion: completion)
    }
    
    func reply(post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let postReply = postToSend(channel: channel, message: message, attachments: attachments)
        postReply.parentId = post.identifier
        postReply.rootId = post.identifier
        RealmUtils.save(postReply)
        
        Api.sharedInstance.sendPost(postReply) { (error) in
            if error != nil { try! RealmUtils.realmForCurrentThread().write({ postReply.status = .error }) }
            completion(error)
            self.clearUploadedAttachments()
        }
    }
}


//MARK: Update
extension PostUtils: Update {
    func update(post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let channelId = post.channelId
        let postId = post.identifier
        Api.sharedInstance.updateSinglePost(post: post, postId: postId!, channelId: channelId!, message: message) { (error) in
            completion(error)
        }
    }
}


//MARK: Delete
extension PostUtils: Delete {
    func delete(post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let dayPrimaryKey = post.day?.key
        guard post.identifier != nil else { completion(nil); return }
        Api.sharedInstance.deletePost(post) { (error) in
            completion(error)
            let realm = RealmUtils.realmForCurrentThread()
            let day = realm.object(ofType: Day.self, forPrimaryKey: dayPrimaryKey)
            guard day?.posts.count == 0 else { return }
            RealmUtils.deleteObject(day!)
        }
    }
}


//MARK: Search
extension PostUtils: Search {
    func search(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>?, _ error: Error?) -> Void) {
        Api.sharedInstance.searchPostsWithTerms(terms: terms, channel: channel) { (posts, error) in
            guard error == nil else {
                if error?.code == -999 {
                    completion(Array(), error)
                } else {
                    completion(nil, error)
                }
                return
            }
            
            completion(posts!, error)
        }
    }
}


//MARK: Upload
extension PostUtils: Upload {
    func upload(items: Array<AssignedAttachmentViewItem>, channel: Channel, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
        self.files.append(contentsOf: items)
        for item in items {
            self.upload_files_group.enter()
            item.uploading = true
            Api.sharedInstance.uploadFileItemAtChannel(item, channel: channel, completion: { (identifier, error) in
                guard self.files.contains(item) else { return }
                
                defer {
                    completion(false, error, item)
                    self.upload_files_group.leave()
                }
                
                guard error == nil else { self.files.removeObject(item); return }
                
                
                let index = self.files.index(where: {$0.identifier == item.identifier})
                if (index != nil) { self.assignedFiles.append(identifier!) }
                }, progress: { (identifier, value) in
                    let index = self.files.index(where: {$0.identifier == identifier})
                    guard (index != nil) else { return }
                    progress(value, index!)
            })
        }
        
        self.upload_files_group.notify(queue: DispatchQueue.main, execute: {
            completion(true, nil, AssignedAttachmentViewItem(image: UIImage()))
        })
    }
    
    func cancelUpload(item: AssignedAttachmentViewItem) {
        Api.sharedInstance.cancelUploadingOperationForImageItem(item)
        let index = self.assignedFiles.index(where: {$0 == item.identifier})
        
        if (index != nil) { self.assignedFiles.remove(at: index!) }
        self.files.removeObject(item)
        
        guard item.uploaded else { return }
        guard self.assignedFiles.count > 0 else { return }
    }
}


fileprivate protocol PostConfiguration: class {
    func postToSend(channel: Channel, message: String, attachments: NSArray?) -> Post
    func assignFilesToPostIfNeeded(_ post: Post)
    func clearUploadedAttachments()
}


//MARK: PostConfiguration
extension PostUtils: PostConfiguration {
    func postToSend(channel: Channel, message: String, attachments: NSArray?) -> Post {
        let post = Post()
        post.message = message
        post.createdAt = Date()
        let lastPostInChannel = channel.lastPost()
        post.authorId = Preferences.sharedInstance.currentUserId
        let postsInterval = (post.createdAt as NSDate?)?.minutesLaterThan(lastPostInChannel?.createdAt)
        post.isFollowUp =  (post.authorId == lastPostInChannel?.authorId) && (postsInterval! < Constants.Post.FollowUpDelay)
        post.channelId = channel.identifier

        post.configureBackendPendingId()
        self.assignFilesToPostIfNeeded(post)
        post.computeMissingFields()
        post.status = .sending
        
        return post
    }
    
    
    func assignFilesToPostIfNeeded(_ post: Post) {
        guard self.assignedFiles.count > 0 else { return }
        
        self.assignedFiles.forEach({
            let file = File.objectById($0)!
            post.files.append(file)
        })
    }
    
    func clearUploadedAttachments() {
        self.assignedFiles.removeAll()
        self.files.removeAll()
    }
}
