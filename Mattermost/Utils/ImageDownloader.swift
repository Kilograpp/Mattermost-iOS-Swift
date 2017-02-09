//
//  ImageDownloader.swift
//  Mattermost
//
//  Created by Maxim Gubin on 11/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage

final class ImageDownloader {
    static func downloadFeedAvatarForUser(_ user: User, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        guard !user.isSystem() else {
            //TODO: Possible refactor
            completion(UIImage.avatarPlaceholderImage/*UIImage.sharedFeedSystemAvatar*/, nil)
            return
        }
        
        let smallAvatarCacheKey = user.smallAvatarCacheKey()
        
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: smallAvatarCacheKey) {
            completion(image, nil)
        } else {
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    
                    // Handle unpredictable errors
                    guard image != nil else {
                        completion(nil, error as NSError?)
                        return
                    }
                    
                    let processedImage = UIImage.roundedImageOfSize(image!, size: CGSize(width: 40, height: 40), backgroundColor: .white)
                    SDImageCache.shared().store(processedImage, forKey: smallAvatarCacheKey)
                    
                    DispatchQueue.main.sync(execute: {
                        completion(processedImage, nil)
                    })
                    

                }
            }
            
            SDWebImageManager.shared().downloadImage(with: user.avatarURL() as URL!,
                                                                   options: [.handleCookies , .retryFailed ] ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }
    }
    
    static func downloadFullAvatarForUser(_ user: User, complection: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        guard !user.isSystem() else {
            complection(UIImage.sharedAvatarPlaceholder, nil)
            return
        }
        
        let fullAvatarCacheKey = user.avatarLink
        
        if let image = SDImageCache.shared().imageFromDiskCache(forKey: fullAvatarCacheKey) {
            complection(image, nil)
        }
        else {
            let imageDownloadComplectionHandler: SDWebImageCompletionWithFinishedBlock = {
                (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                    guard image != nil else {
                        complection(nil, error as NSError?)
                        return
                    }
                    
                    let processedImage = UIImage.roundedImageOfSize(image!, size: CGSize(width: 130, height: 130), backgroundColor: .white)
                    SDImageCache.shared().store(processedImage, forKey: fullAvatarCacheKey)
                    
                    DispatchQueue.main.sync(execute: {
                        complection(processedImage, nil)
                    })
                }
            }
            
            SDWebImageManager.shared().downloadImage(with: user.avatarURL() as URL!,
                                                                   options: [.handleCookies , .retryFailed ] ,
                                                                   progress: nil,
                                                                   completed: imageDownloadComplectionHandler)
        }
    }
}
