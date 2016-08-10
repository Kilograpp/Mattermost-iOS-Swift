//
//  AttachmentImageCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 04/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import WebImage

final class AttachmentImageCell: UITableViewCell, Reusable {
    private var file: File! {
        didSet {
            computeFileName()
        }
    }
    private var fileName: String?
    private let fileImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupImageView() {
        self.fileImageView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.fileImageView.contentMode = .ScaleAspectFit
        self.addSubview(self.fileImageView)
    }
    
    func configureWithFile(file: File) {
        self.file = file
        self.configureImageView()
        
    }
    
    private func configureImageView() {
        
        let fileName = self.fileName
        let downloadUrl = self.file.thumbURL()!
        
        if let image = SDImageCache.sharedImageCache().imageFromMemoryCacheForKey(downloadUrl.absoluteString) {
            self.fileImageView.image = image
        } else {
            self.fileImageView.image = nil
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    
                    var finalImage: UIImage = image
                    
                    // Handle unpredictable errors
                    guard image != nil else {
                        print(error)
                        return
                    }
                    
                    if cacheType == .None {
                        let imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
                        let imageHeight = imageWidth * 0.56 - 5
                        
                        finalImage = image.imageByScalingAndCroppingForSize(CGSize(width: imageWidth, height: imageHeight), radius: 3)
                        SDImageCache.sharedImageCache().storeImage(finalImage, forKey: downloadUrl.absoluteString)
                    }
                    

                    // Ensure the post is still the same
                    guard self?.fileName == fileName else {
                        return
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        self?.fileImageView.image = finalImage
                    })
                    
                }
            }
            
            SDWebImageManager.sharedManager().downloadImageWithURL(downloadUrl,
                                                                   options: .HandleCookies ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }

    }
    
    private func computeFileName() {
        self.fileName = self.file?.name
    }
    
    override func layoutSubviews() {
        self.fileImageView.frame = self.bounds
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        self.file = nil
    }
    
}