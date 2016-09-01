//
//  ImageDownloader.swift
//  Mattermost
//
//  Created by Maxim Gubin on 11/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage

final class ImageDownloader {
    static func downloadFeedAvatarForUser(user: User, completion: (image: UIImage?, error: NSError?) -> Void) {
        guard !user.isSystem() else {
            completion(image: UIImage.sharedFeedSystemAvatar, error: nil)
            return
        }
        
        let smallAvatarCacheKey = user.smallAvatarCacheKey()
        
        if let image = SDImageCache.sharedImageCache().imageFromMemoryCacheForKey(smallAvatarCacheKey) {
            completion(image: image, error: nil)
        } else {
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                (image, error, cacheType, isFinished, imageUrl) in
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    
                    // Handle unpredictable errors
                    guard image != nil else {
                        completion(image: nil, error: error)
                        return
                    }
                    
                    let processedImage = UIImage.roundedImageOfSize(image, size: CGSizeMake(40, 40))
                    SDImageCache.sharedImageCache().storeImage(processedImage, forKey: smallAvatarCacheKey)
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        completion(image: processedImage, error: nil)
                    })
                    

                }
            }
            
            SDWebImageManager.sharedManager().downloadImageWithURL(user.avatarURL(),
                                                                   options: .HandleCookies ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }
    }
}