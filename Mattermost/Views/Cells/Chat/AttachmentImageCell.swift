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
}

final class AttachmentImageCell: UITableViewCell, Reusable, Attachable {
    
//MARK: Properties
    fileprivate var file: File! {
        didSet { computeFileName() }
    }
    fileprivate var fileName: String?
    fileprivate let fileImageView = UIImageView()
    fileprivate let fileNameLabel = UILabel()
    
    fileprivate let downloadIconImageView = UIImageView()
    fileprivate let progressView = MRCircularProgressView()
    
    var downloadingState: Int = DownloadingState.NotDownloaded {
        didSet { updateIconForCurrentState() }
    }
    
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
        self.downloadIconImageView.center = self.fileImageView.center
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
        configureDownloadingState()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupImageView()
    func setupLabel()
    func setupDownloadIcon()
    func setupProgressView()
}

fileprivate protocol Updating: class {
    func configureLabel()
    func configureImageView()
    func updateIconForCurrentState()
    func computeFileName()
}

fileprivate protocol Action: class {
    func tapAction()
}

fileprivate protocol Downloading: class {
    func startDownloadingFile()
    func stopDownloadingFile()
    func openDownloadedFile()
}


//MARK: Setup
extension AttachmentImageCell: Setup {
    func initialSetup() {
        setupImageView()
        setupLabel()
        setupDownloadIcon()
        setupProgressView()
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
    
    fileprivate func setupDownloadIcon() {
        self.downloadIconImageView.backgroundColor = UIColor.clear
        self.downloadIconImageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        self.downloadIconImageView.isHidden = true
        self.addSubview(self.downloadIconImageView)
    }
    
    fileprivate func setupProgressView() {
        self.progressView.frame = CGRect(x: 7, y: 7, width: 30, height: 30)
        
        self.progressView.backgroundColor = UIColor.clear
        self.progressView.valueLabel.isHidden = true
        self.progressView.borderWidth = 0
        self.progressView.lineWidth = 2
        self.progressView.tintColor = ColorBucket.whiteColor
        self.progressView.isHidden = true
        self.downloadIconImageView.addSubview(self.progressView)
    }
}


//MARK: Configuration
extension AttachmentImageCell: Updating {
    fileprivate func configureDownloadingState() {
        self.downloadIconImageView.isHidden = false
        if file.downoloadedSize == file.size {
            self.downloadingState = DownloadingState.Downloaded
        } else {
            self.downloadingState = (file.downoloadedSize == 0) ? DownloadingState.NotDownloaded
                : DownloadingState.Downloading
        }
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
        /*
        if (downloadUrl.absoluteString.contains("(null)")) {
            let fixedPath = downloadUrl.absoluteString.replacingOccurrences(of: "(null)", with: Preferences.sharedInstance.currentTeamId!)
            downloadUrl = NSURL(string: fixedPath)! as URL
        }*/
        
        if (downloadUrl.absoluteString.contains(NullString)) {
            let fixedPath = downloadUrl.absoluteString.replacingOccurrences(of: NullString, with: Preferences.sharedInstance.currentTeamId!)
            downloadUrl = NSURL(string: fixedPath)! as URL
        }
        
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: downloadUrl.absoluteString) {
            self.fileImageView.image = image
        } else {
            self.fileImageView.image = UIImage(named: "image_back")
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    // Handle unpredictable errors
                    guard image != nil else { return }
                    
                    var finalImage: UIImage = image!
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
    
    fileprivate func updateIconForCurrentState() {
        switch self.downloadingState {
        case DownloadingState.NotDownloaded:
            self.downloadIconImageView.image = UIImage(named: "chat_notdownloaded_icon")
        case DownloadingState.Downloading:
            self.downloadIconImageView.image = UIImage(named: "chat_downloading_icon")
        case DownloadingState.Downloaded:
            self.downloadIconImageView.image = UIImage(named: "chat_downloaded_icon")
        default:
            break
        }
    }
    
    fileprivate func computeFileName() {
        self.fileName = self.file?.name
    }
}


//MARK: Action
extension AttachmentImageCell: Action {
    @objc fileprivate func tapAction() {
        switch self.downloadingState {
        case DownloadingState.NotDownloaded:
            startDownloadingFile()
        case DownloadingState.Downloading:
            stopDownloadingFile()
        case DownloadingState.Downloaded:
            openDownloadedFile()
        default:
            break
        }
    }
}



extension AttachmentImageCell: Downloading {
    fileprivate func startDownloadingFile() {
        self.progressView.isHidden = false
        self.downloadingState = DownloadingState.Downloading
        let fileId = self.file.identifier
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            Api.sharedInstance.download(fileId: fileId!, completion: { (error) in
                self.progressView.isHidden = true
                guard error == nil else {
                    AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)//, viewController: UIViewController())
                    return
                }
                self.downloadingState = DownloadingState.Downloaded
                
                AlertManager.sharedManager.showSuccesWithMessage(message: "File was successfully downloaded"/* , viewController: UIViewController()*/)
                
                let notification = UILocalNotification()
                notification.alertBody = "File was successfully downloaded"
                notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                UIApplication.shared.scheduleLocalNotification(notification)
                
            }) { (identifier, progress) in
                print("progressTotal = ", progress)
                if fileId == identifier {
                    print("progress = ", progress)
                    self.progressView.progress = progress
                }
            }
        })
    }
    
    fileprivate func stopDownloadingFile() {
        self.downloadingState = DownloadingState.NotDownloaded
        self.progressView.isHidden = true
        Api.sharedInstance.cancelDownloading(fileId: self.file.identifier!)
    }
    
    fileprivate func openDownloadedFile() {
        let fileId = self.file.identifier
        let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.DocumentInteractionNotification),
                                        object: nil, userInfo: ["fileId" : fileId!])
        NotificationCenter.default.post(notification as Notification)
    }
}

