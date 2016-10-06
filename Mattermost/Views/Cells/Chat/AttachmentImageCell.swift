//
//  AttachmentImageCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 04/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import WebImage

final class AttachmentImageCell: UITableViewCell, Reusable, Attachable {
    fileprivate var file: File! {
        didSet { computeFileName() }
    }
    fileprivate var fileName: String?
    fileprivate let fileImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupImageView() {
        self.fileImageView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.fileImageView.contentMode = .scaleAspectFit
        self.addSubview(self.fileImageView)
    }
    
    func configureWithFile(_ file: File) {
        self.file = file
        self.configureImageView()
        
    }
    
    fileprivate func configureImageView() {
        
        let fileName = self.fileName
        var downloadUrl = self.file.thumbURL()!
        
//MARK: addition for search attachment cell
        if (downloadUrl.absoluteString.contains("(null)")) {
            let fixedPath = downloadUrl.absoluteString.replacingOccurrences(of: "(null)", with: Preferences.sharedInstance.currentTeamId!)
            downloadUrl = NSURL(string: fixedPath)! as URL
        }
        
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: downloadUrl.absoluteString) {
            self.fileImageView.image = image
        } else {
            self.fileImageView.image = nil
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    
                    var finalImage: UIImage = image!
                    
                    // Handle unpredictable errors
                    guard image != nil else {
                        print(error)
                        return
                    }
                    
                    if cacheType == .none {
                        let imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
                        let imageHeight = imageWidth * 0.56 - 5
                        
                        finalImage = image!.imageByScalingAndCroppingForSize(CGSize(width: imageWidth, height: imageHeight), radius: 3)
                        SDImageCache.shared().store(finalImage, forKey: downloadUrl.absoluteString)
                    }
                    

                    // Ensure the post is still the same
                    guard self?.fileName == fileName else {
                        return
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        self?.fileImageView.image = finalImage
                    })
                    
                }
            }
            
            SDWebImageManager.shared().downloadImage(with: downloadUrl as URL!,
                                                                   options: .handleCookies ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }

    }
    
    fileprivate func computeFileName() {
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
