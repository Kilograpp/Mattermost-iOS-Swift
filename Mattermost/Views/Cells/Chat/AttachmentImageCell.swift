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
    fileprivate let fileNameLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        setupImageView()
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupImageView() {
//        self.fileImageView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.fileImageView.contentMode = .scaleToFill
        self.addSubview(self.fileImageView)
        self.fileImageView.backgroundColor = UIColor.clear
        self.fileImageView.contentMode = .scaleAspectFit
    }
    
    fileprivate func setupLabel() {
        fileNameLabel.font = UIFont.systemFont(ofSize: 13)
        fileNameLabel.textColor = ColorBucket.blueColor
        fileNameLabel.numberOfLines = 0
        self.addSubview(fileNameLabel)
    }
    
    func configureWithFile(_ file: File) {
        self.file = file
        configureImageView()
        configureLabel()
    }
    
    fileprivate func configureLabel() {
        guard fileName != nil else { return }
        fileNameLabel.text = fileName
        fileNameLabel.sizeToFit()
        self.layoutSubviews()
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
                    guard image != nil else { return }
                    
                    if cacheType == .none {
                        var imageWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
                        let imageHeight = imageWidth * 0.56 - 5
                        imageWidth = imageHeight / (image?.size.height)! * (image?.size.width)!
                        
                        finalImage = image!.imageByScalingAndCroppingForSize(CGSize(width: imageWidth, height: imageHeight), radius: 3)
                        SDImageCache.shared().store(finalImage, forKey: downloadUrl.absoluteString)
                    }
                    
                    // Ensure the post is still the same
                    guard self?.fileName == fileName else { return }
                    
                    DispatchQueue.main.sync(execute: {
                        self?.fileImageView.image = finalImage
                    })
                }
            }
            
            SDWebImageManager.shared().downloadImage(with: downloadUrl as URL!,
                                                                   options: [ .handleCookies, .retryFailed ] ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }
    }
    
    fileprivate func computeFileName() {
        self.fileName = self.file?.name
    }
    
    override func layoutSubviews() {
        self.fileNameLabel.sizeToFit()
        self.fileNameLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.fileNameLabel.frame.height)
        
        
        let height = self.bounds.height - self.fileNameLabel.frame.height
        let width = self.bounds.width
        
        self.fileImageView.frame = CGRect(x: 0, y: self.fileNameLabel.frame.height, width: width, height: height)
        
//        self.fileImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width * 0.6, height: self.bounds.height)
//        self.fileNameLabel.frame = CGRect(x: self.bounds.width * 0.6,
//                                          y: self.bounds.height / 2 - self.fileNameLabel.frame.height,
//                                          width: self.bounds.width * 0.4,
//                                          height: self.fileNameLabel.frame.height)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        self.file = nil
    }
    
}
