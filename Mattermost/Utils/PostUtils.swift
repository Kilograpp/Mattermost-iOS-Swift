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
    func removeAttachmentAtIdex(_ identifier: String)
    func updateCached(files: [AssignedAttachmentViewItem])
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
    func upload(items: Array<AssignedAttachmentViewItem>, channel: Channel, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ item: AssignedAttachmentViewItem) -> Void)
    func cancelUpload(item: AssignedAttachmentViewItem)
}


final class PostUtils: NSObject {
//MARK: Properies
    static let sharedInstance = PostUtils()
    fileprivate let upload_files_group = DispatchGroup()
    fileprivate var files = Array<AssignedAttachmentViewItem>()
    fileprivate var unsortedIdentifiers = [(Int, String)]()
    
    fileprivate var assignedFiles: Array<String> = Array()
}


//MARK: Interface
extension PostUtils: Interface {
    func removeAttachmentAtIdex(_ identifier: String) {
        guard let index = self.files.index(where: {$0.identifier == identifier}) else { return }
        if files.indices.contains(index) { files.remove(at: index) }
        guard let assignIndex = self.assignedFiles.index(where: {$0 == identifier}) else { return }
        if assignedFiles.indices.contains(assignIndex) { assignedFiles.remove(at: index) }
    }
    
    func updateCached(files: [AssignedAttachmentViewItem]) {
        for file in files {
            //if !self.assignedFiles.contains(file.identifier) { self.assignedFiles.append(file.identifier) }
        }
    }
}


//MARK: Send
extension PostUtils: Send {
    func sendPost(channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let trimmedMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let post = postToSend(channel: channel, message: trimmedMessage, attachments: attachments)
        print(post.files.count)
        guard trimmedMessage != StringUtils.emptyString() || post.files.count > 0  else {
            AlertManager.sharedManager.showWarningWithMessage(message: "Text shouldn't contain only whitespaces and newlines")
            return
        }
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
        let countOfPostsInDay = post.day?.posts.count
        let postWasFollowUp = post.isFollowUp
        let index = post.day?.sortedPosts().index(of: post)
        guard post.identifier != nil else {
            deleteLocalPost(postId: post.localIdentifier!, dayId: dayPrimaryKey!)
            completion(nil)
            return
        }
        Api.sharedInstance.deletePost(post) { (error) in
            let realm = RealmUtils.realmForCurrentThread()
            
            try! realm.write {
                let day = realm.object(ofType: Day.self, forPrimaryKey: dayPrimaryKey)
                if countOfPostsInDay! > 1 && !postWasFollowUp && (day?.sortedPosts().indices.contains(index!))! {
                    let oldNextPost = day?.sortedPosts()[index!]
                    oldNextPost?.isFollowUp = false
                    realm.add(oldNextPost!, update: true)
                }
                guard day?.posts.count == 0 else { return }
                RealmUtils.deleteObject(day!)
            }
            completion(error)
        }
    }
    
    func deleteLocalPost(postId: String, dayId: String) {
        let realm = RealmUtils.realmForCurrentThread()
        try! realm.write {
            let post = realm.object(ofType: Post.self, forPrimaryKey: postId)
            realm.delete(post!)
            let day = realm.object(ofType: Day.self, forPrimaryKey: dayId)
            guard day?.posts.count == 0 else { return }
            realm.delete(day!)
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
    func upload(items: Array<AssignedAttachmentViewItem>, channel: Channel, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ item: AssignedAttachmentViewItem) -> Void) {
        self.files.append(contentsOf: items)
        for item in items {
            self.upload_files_group.enter()
            item.uploading = true
            Api.sharedInstance.uploadFileItemAtChannel(item, channel: channel, completion: { (identifier, error) in
//                guard self.files.contains(item) else {
//                    return
//                }
                
                defer {
                    self.upload_files_group.leave()
                    completion(false, error, item)
                }
                
                guard error == nil else {
                    guard self.files.contains(item) else {
                        return
                    }
                    self.files.removeObject(item);
                    return
                }
                
                
                let index = self.files.index(where: {$0.identifier == item.identifier})
                if (index != nil) {
                    item.backendIdentifier = identifier
                    self.assignedFiles.append(identifier!)
                    self.unsortedIdentifiers.append((index!, identifier!))
                }
                if index == nil {
                    
                }
                }, progress: { (item, value) in
                    guard let index = self.files.index(where: {$0.identifier == item.identifier}) else { return }
                    let item = self.files[index]
                    progress(value, item)
            })
        }
        
        self.upload_files_group.notify(queue: DispatchQueue.main, execute: {
            completion(true, nil, AssignedAttachmentViewItem(image: UIImage()))
        })
    }
    
    func cancelUpload(item: AssignedAttachmentViewItem) {
        //identifiers in assignedFiles != item.identifier
        Api.sharedInstance.cancelUploadingOperationForImageItem(item)
        let index = self.assignedFiles.index(where: {$0 == item.backendIdentifier})
        if (index != nil) { self.assignedFiles.remove(at: index!) }
        let sortedIndex = self.unsortedIdentifiers.index(where: {$0.1 == item.backendIdentifier})
        if (sortedIndex != nil) { unsortedIdentifiers.remove(at: sortedIndex!) }
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
        
        let sortedIdentifiers = unsortedIdentifiers.sorted(by: {$0.0 < $1.0})
        
        sortedIdentifiers.forEach({
            let file = File.objectById($0.1)!
            post.files.append(file)
        })
    }
    
    func clearUploadedAttachments() {
        self.assignedFiles.removeAll()
        self.files.removeAll()
        self.unsortedIdentifiers.removeAll()
    }
}
