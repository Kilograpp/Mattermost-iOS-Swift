//
//  AttachmentImageCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 04/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import WebImage
import MRProgress

fileprivate struct DownloadingState {
    static let NotDownloaded: Int = 0
    static let Downloading: Int = 1
    static let Downloaded: Int  = 2
}

fileprivate let NullString = "(null)"

protocol AttachmentImageCellConfiguration: class {
    func configureWithFile(_ file: File)
   // func heightWith(file: File) -> CGFloat
}

final class AttachmentImageCell: UITableViewCell, Reusable, Attachable {
    
//MARK: Properties
    fileprivate var file: File! {
        didSet { computeFileName() }
    }
    fileprivate var fileName: String?
    fileprivate let fileImageView = UIImageView()
    fileprivate let fileNameLabel = UILabel()
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        self.fileNameLabel.sizeToFit()
        self.fileNameLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.fileNameLabel.frame.height)
        
        let height = self.bounds.height - self.fileNameLabel.frame.height
        let width = self.bounds.width
        
        self.fileImageView.frame = CGRect(x: 0, y: self.fileNameLabel.frame.height, width: width, height: height)
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        self.file = nil
    }
}


//MARK: AttachmentImageCellConfiguration
extension AttachmentImageCell: AttachmentImageCellConfiguration {
    func configureWithFile(_ file: File) {
        self.file = file
        configureImageView()
        configureLabel()
    }
    
    func heightWith(file: File) -> CGFloat {
        //if let image = SDImageCache.shared().imageFromMemoryCache(forKey: downloadUrl.absoluteString) {
            //return ima
        //}
        //let width = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
        //let scale = width / finalImage.size.width
        //let height = finalImage.size.height * scale
        
        return 0
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupImageView()
    func setupLabel()
}

fileprivate protocol Updating: class {
    func configureLabel()
    func configureImageView()
    func computeFileName()
}

fileprivate protocol Action: class {
    func tapAction()
}


//MARK: Setup
extension AttachmentImageCell: Setup {
    func initialSetup() {
        setupImageView()
        setupLabel()
    }
    
    fileprivate func setupImageView() {
        self.fileImageView.contentMode = .scaleToFill
        self.addSubview(self.fileImageView)
        self.fileImageView.backgroundColor = UIColor.clear
        self.fileImageView.contentMode = .scaleAspectFit
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.fileImageView.isUserInteractionEnabled = true
        self.fileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupLabel() {
        fileNameLabel.font = UIFont.systemFont(ofSize: 13)
        fileNameLabel.textColor = ColorBucket.blueColor
        fileNameLabel.numberOfLines = 1
        self.addSubview(fileNameLabel)
    }
}


//MARK: Configuration
extension AttachmentImageCell: Updating {
    fileprivate func configureLabel() {
        guard fileName != nil else { return }
        fileNameLabel.text = fileName
        fileNameLabel.sizeToFit()
        self.layoutSubviews()
    }
    
    fileprivate func configureImageView() {
        let fileName = self.fileName
        var downloadUrl = self.file.thumbURL()!
        
        if (downloadUrl.absoluteString.contains(NullString)) {
            let fixedPath = downloadUrl.absoluteString.replacingOccurrences(of: NullString, with: Preferences.sharedInstance.currentTeamId!)
            downloadUrl = NSURL(string: fixedPath)! as URL
        }
        
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: downloadUrl.absoluteString) {
            self.fileImageView.image = image
            print("sfsdfsdf ", image.size)
        } else {
            self.fileImageView.image = UIImage(named: "image_back")
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    // Handle unpredictable errors
                    guard image != nil else { return }
                    
                    var finalImage: UIImage = image!
                    if cacheType == .none {
                        let width = UIScreen.screenWidth() - Constants.UI.DoublePaddingSize
                        let scale = width / finalImage.size.width
                        let height = finalImage.size.height * scale
                        
                        print("width = ", width, "heigth = ", height)
                        
                        finalImage = image!.imageByScalingAndCroppingForSize(CGSize(width: width, height: height), radius: 3)
                        SDImageCache.shared().store(finalImage, forKey: downloadUrl.absoluteString)
                    }
                    
                    // Ensure the post is still the same
                    guard self?.fileName == fileName else { return }
                    
                    DispatchQueue.main.sync(execute: {
                        self?.fileImageView.image = finalImage
                        let postLocalId = self?.file.post?.localIdentifier
                        
                        guard postLocalId != nil else { return }
                        
                        let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.ReloadChatNotification),
                                                        object: nil, userInfo: ["postLocalId" : postLocalId])
                        NotificationCenter.default.post(notification as Notification)
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
}


//MARK: Action
extension AttachmentImageCell: Action {
    @objc fileprivate func tapAction() {
        let postLocalId = self.file.post?.localIdentifier
        let fileId = self.file.identifier
        let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.FileImageDidTapNotification),
                                        object: nil, userInfo: ["postLocalId" : postLocalId, "fileId" : fileId])
        NotificationCenter.default.post(notification as Notification)
    }
}
