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
    static let Downloading: Int   = 1
    static let Downloaded: Int    = 2
}

fileprivate let NullString = "(null)"
fileprivate let TitleFont = UIFont.systemFont(ofSize: 13)
fileprivate let emptyImageViewBackgroundColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)

protocol AttachmentImageCellConfiguration: class {
    func configureWithFile(_ file: File)
    static func heightWithFile(_ file: File) -> CGFloat
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
        super.layoutSubviews()
        
        guard self.file != nil else { return }
        
        self.fileNameLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 20)
        self.fileImageView.frame = CGRect(x: 0,
                                          y: self.fileNameLabel.frame.maxY,
                                          width: self.bounds.width,
                                          height: bounds.height - 21)
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
    
    static func heightWithFile(_ file: File) -> CGFloat {
        let baseHeight: CGFloat = 20
        let imageHeight = FileUtils.scaledImageHeightWith(file: file)
        
        return baseHeight + imageHeight
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
        setupGestureRecognizers()
    }
    
    fileprivate func setupImageView() {
        self.addSubview(self.fileImageView)
        //was clear
        self.fileImageView.contentMode = .center
        self.fileImageView.backgroundColor = emptyImageViewBackgroundColor
    }
    
    fileprivate func setupLabel() {
        fileNameLabel.font = TitleFont
        fileNameLabel.textColor = ColorBucket.blueColor
        fileNameLabel.backgroundColor = ColorBucket.whiteColor
        fileNameLabel.numberOfLines = 1
        self.addSubview(fileNameLabel)
    }
    
    fileprivate func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}


//MARK: Configuration
extension AttachmentImageCell: Updating {
    fileprivate func configureLabel() {
        guard fileName != nil else { return }
        fileNameLabel.text = fileName
    }
    
    fileprivate func configureImageView() {
        let fileName = self.fileName
        var downloadUrl = self.file.previewURL()
        let size = FileUtils.scaledImageSizeWith(file: self.file!)
        
        if (downloadUrl?.absoluteString.contains(NullString))! {
            let fixedPath = downloadUrl?.absoluteString.replacingOccurrences(of: NullString, with: Preferences.sharedInstance.currentTeamId!)
            downloadUrl = NSURL(string: fixedPath!)! as URL
        }
        
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: downloadUrl?.absoluteString) {
            self.fileImageView.image = image
        } else {
            self.fileImageView.image = Constants.Post.BackImage
            
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    // Handle unpredictable errors
                    guard image != nil else { return }
                    
                    var finalImage: UIImage = image!
                    if cacheType == .none {
                        finalImage = image!.imageByScalingAndCroppingForSize(size, radius: 3)
                        SDImageCache.shared().store(finalImage, forKey: downloadUrl?.absoluteString)
                    }
                    
                    // Ensure the post is still the same
                    guard self?.fileName == fileName else { return }
                    
                    DispatchQueue.main.async(execute: {
                        let postLocalId = self?.file.post?.localIdentifier
                        guard postLocalId != nil else { return }
                        
                        self?.fileImageView.image = finalImage
                        self?.fileImageView.backgroundColor = UIColor.white
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
                                        object: nil, userInfo: ["postLocalId" : postLocalId!, "fileId" : fileId!])
        NotificationCenter.default.post(notification as Notification)
    }
}
