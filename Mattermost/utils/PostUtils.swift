//
//  PostUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

// CODEREVIEW: Лишний импорт
import Foundation
// CODEREVIEW: Лишний импорт, достаточно RealmSwift
import Realm
import RealmSwift

// CODEREVIEW: Везде забыты extensions по категориям


// CODEREVIEW: Fileprivate должен быть
// CODEREVIEW: Слишком много методов для одного протокола, стоит разнести на несколько
private protocol Public : class {
    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func sendExistingPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func resendPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func sendReplyToPost(_ post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func updateSinglePost(_ post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void)
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void)
//    func uploadImages(_ channel: Channel, images: Array<AssignedAttachmentViewItem>, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void,  progress:@escaping (_ value: Float, _ index: Int) -> Void)
    func searchTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>, _ error: Error?) -> Void)
    func cancelImageItemUploading(_ item: AssignedAttachmentViewItem)
}

// CODEREVIEW: Приватные методы должны быть под классом
// CODEREVIEW: Не private, а конкретный функционал. Категория должна обозначать конкретные функции
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
    // CODEREVIEW: Опечатка в слове senD
    // CODEREVIEW: переименовать в sendPost(channel:, message:, attachments:, completion:). Длинные предварительные названия - это не Swift way'
    // CODEREVIEW: Лишний -> void в конце 

    func sentPostForChannel(with channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        let postToSend = Post()
        
//        RealmUtils.save(self.assignedFiles)
        // CODEREVIEW: Нарушения абстракции. Лучше вынести логику еще в отдельный приватный метод, чтобы держать интерфейсные в чистоте.
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
        self.files.forEach { (item) in
            // CODEREVIEW: Нужен guard
            if !item.uploaded {
                self.cancelImageItemUploading(item)
            }
        }
    }
    
    // CODEREVIEW: Переименовтаь в send(post)
    func sendExistingPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        Api.sharedInstance.sendPost(post) { (error) in
            completion(error)
            // CODEREVIEW: Нужен guard вместо if
            if error != nil {
                print("error")
                try! RealmUtils.realmForCurrentThread().write({
                    post.status = .error
                })
            }
            
        }
    }
    
    // CODEREVIEW: Переименовать в resend(post)
    func resendPost(_ post:Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        try! RealmUtils.realmForCurrentThread().write({
            post.status = .sending
        })
        sendExistingPost(post, completion: completion)
    }
    
    // CODEREVIEW: Переименовать в reply(post)
    func sendReplyToPost(_ post: Post, channel: Channel, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        // CODEREVIEW: Нарушения абстракции в методе. Тоже самое, что и в первом самом
        let postToSend = Post()
        
        postToSend.message = message
        postToSend.createdAt = Date()
        postToSend.channelId = channel.identifier
        postToSend.authorId = Preferences.sharedInstance.currentUserId
        postToSend.parentId = post.identifier
        postToSend.rootId = post.identifier
        postToSend.status = .sending
        self.configureBackendPendingId(postToSend)
        self.assignFilesToPostIfNeeded(postToSend)
        postToSend.computeMissingFields()
        RealmUtils.save(postToSend)
        
        Api.sharedInstance.sendPost(postToSend) { (error) in
            // CODEREVIEW: Нужен guard
            if error != nil {
                print("error")
                try! RealmUtils.realmForCurrentThread().write({
                    postToSend.status = .error
                })
            }
            completion(error)
            self.clearUploadedAttachments()
        }
    }

    // CODEREVIEW: переименовать в update(post
    // CODEREVIEW: Убрать -> void
    func updateSinglePost(_ post: Post, message: String, attachments: NSArray?, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        // CODEREVIEW: Каша из абстракций.
        try! RealmUtils.realmForCurrentThread().write({
            post.message = message
            post.updatedAt = NSDate() as Date
            configureBackendPendingId(post)
            assignFilesToPostIfNeeded(post)
            post.computeMissingFields()
        })
    
        Api.sharedInstance.updateSinglePost(post) { (error) in
            completion(error)
        }
    }
    
    // CODEREVIEW:  Переименовать в delete(post
    // CODEREVIEW: Убрать -> void
    func deletePost(_ post: Post, completion: @escaping (_ error: Mattermost.Error?) -> Void) {
        // identifier == nil -> post exists only in database
        let day = post.day
        guard post.identifier != nil else {
            completion(nil)
            return
        }
        Api.sharedInstance.deletePost(post) { (error) in
            completion(error)
            guard day?.posts.count == 0 else { return }
            RealmUtils.deleteObject(day!)
            
        }
    }
    //refactor uploadItemAtChannel
    // CODEREVIEW: Переименовать в upload(file: Assignedattac.., channel: )
    // CODEREVIEW: Убрать -> Void
    // CODEREVIEW: Убрать _. Нет необходимости проглатывать параметры
    func uploadFiles(_ channel: Channel,fileItem:AssignedAttachmentViewItem, url:URL, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
            self.files.append(fileItem)
            self.upload_images_group.enter()
            Api.sharedInstance.uploadFileItemAtChannel(fileItem, channel: channel, completion: { (file, error) in
                completion(true, error)
                // CODEREVIEW: Гард
                if error != nil {
                    self.files.removeObject(fileItem)
                    return
                }
                self.assignedFiles.append(file!)
                print("uploaded")
            }) { (identifier, value) in
                
                // CODEREVIEW: Guard кривой. Должен быть сразу гард, оборачивающий выражение
                let index = self.files.index(where: {$0.identifier == identifier})
                guard (index != nil) else {
                    return
                }
                print("\(index) in progress: \(value)")
                progress(value, index!)
            }
        
        self.upload_images_group.notify(queue: DispatchQueue.main, execute: {
            //FIXME: add error
            completion(true, nil)
        })
    }
    

    // CODEREVIEW: Переименовать в search(terms:
    func searchTerms(terms: String, channel: Channel, completion: @escaping(_ posts: Array<Post>, _ error: Error?) -> Void) {
        Api.sharedInstance.searchPostsWithTerms(terms: terms, channel: channel) { (posts, error) in
            // CODEREVIEW: guard
            if error?.code == -999 {
                completion(Array(), error)
            }
            else {
                completion(posts!, error)
            }
        }
    }
    
    // CODEREVIEW: Убить
//    func uploadImages(_ channel: Channel, images: Array<AssignedAttachmentViewItem>, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
//        self.files.append(contentsOf: images)
//        for item in files {
//            if !item.uploaded && !item.isFile {
//                self.upload_images_group.enter()
//                item.uploading = true
//                Api.sharedInstance.uploadImageItemAtChannel(item, channel: channel, completion: { (file, error) in
//                    completion(false, error, item)
//                    if error != nil {
//                        self.files.removeObject(item)
//                        return
//                    }
//                    
//                    if self.assignedFiles.count == 0 {
//                        self.test = file
//                    }
//                    self.assignedFiles.append(file!)
//                    self.upload_images_group.leave()
//                    }, progress: { (identifier, value) in
//                        let index = self.files.index(where: {$0.identifier == identifier})
//                        guard (index != nil) else {
//                            return
//                        }
//                        progress(value, index!)
//                })
//            }
//            
//            self.upload_images_group.notify(queue: DispatchQueue.main, execute: {
//                //FIXME: add error
//                completion(true, nil, item)
//            })
//        }
//    }
    
    // CODEREVIEW: Переименовать в upload(items, channel)
    func uploadAttachment(_ channel: Channel, items: Array<AssignedAttachmentViewItem>, completion: @escaping (_ finished: Bool, _ error: Mattermost.Error?, _ item: AssignedAttachmentViewItem) -> Void, progress:@escaping (_ value: Float, _ index: Int) -> Void) {
        self.files.append(contentsOf: items)
        // CODEREVIEW: Лишний отступ
            for item in items {
                print("\(item.identifier) is starting")
                self.upload_images_group.enter()
                item.uploading = true
                Api.sharedInstance.uploadFileItemAtChannel(item, channel: channel, completion: { (file, error) in

                    guard self.files.contains(item) else { return }
                    
                    defer {
                        completion(false, error, item)
                        self.upload_images_group.leave()
                        print("\(item.identifier) is finishing")
                    }
                    guard error == nil else {
                        self.files.removeObject(item)
                        return
                    }
                    self.assignedFiles.append(file!)
                    
                    if self.assignedFiles.count == 0 {
                        self.test = file
                    }
                    
                    let index = self.files.index(where: {$0.identifier == item.identifier})
                    if (index != nil) {
                        self.assignedFiles.append(file!)
                        print("uploaded")
                    }
                    
                    //print("uploaded")
                    //self.assignedFiles.append(file!)
                    self.upload_images_group.leave()
                    }, progress: { (identifier, value) in
                        let index = self.files.index(where: {$0.identifier == identifier})
                        guard (index != nil) else { return }
                        print("\(index) in progress: \(value)")
                        progress(value, index!)
                })
            }
        
        self.upload_images_group.notify(queue: DispatchQueue.main, execute: {
            //FIXME: add error
            print("UPLOADING NOTIFY")
            //completion(false,nil,item=nil)
            completion(true, nil, AssignedAttachmentViewItem(image: UIImage()))
        })
    }
    
    
    // CODEREVIEW: Убить
//    func assignFilesToPost(post: Post) {
//        post.files = List(self.assignedFiles)
//    }
    
    // CODEREVIEW: Переименовать в cancelUpload(item:
    // CODEREVIEW: В целом немного кривоватый метод, потом будет дополнительное ревью с конкретными уточнениями, что можно сделать
    func cancelImageItemUploading(_ item: AssignedAttachmentViewItem) {
        Api.sharedInstance.cancelUploadingOperationForImageItem(item)
        self.upload_images_group.leave()

        if item.uploaded  {
            self.assignedFiles.remove(at: files.index(of: item)!)
        }
        
        
        let index = self.assignedFiles.index(where: {$0.identifier == item.identifier})
        
        if (index != nil) {
            self.assignedFiles.remove(at: index!)
        }
        self.files.removeObject(item)
        
        guard item.uploaded else { return }
        guard self.assignedFiles.count > 0 else { return }
        self.assignedFiles.remove(at: files.index(of: item)!)
        
    }
}


extension PostUtils : Private {
    fileprivate func assignFilesToPostIfNeeded(_ post: Post) {
        // CODEREVIEW: Должен быть guard вместо if
        if self.assignedFiles.count > 0 {
            post.files.append(objectsIn: self.assignedFiles)
        }
    }
    
    func clearUploadedAttachments() {
        self.assignedFiles.removeAll()
        self.files.removeAll()
    }
}
