//
//  AttachmentFileView.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 14.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import MBProgressHUD
import MRProgress

fileprivate struct DownloadingState {
    static let NotDownloaded: Int = 0
    static let Downloading: Int = 1
    static let Downloaded: Int  = 2
}

class AttachmentFileView: UIView {
    
//MARK: Properties
    let iconImageView = UIImageView()
    let progressView = MRCircularProgressView()
    var file: File!
    
    var tapHandler: (() -> Void)?
    
    var downloadingState: Int = DownloadingState.NotDownloaded {
        didSet { updateIconForCurrentState() }
    }

//MARK: LifeCycle
    init(file: File, frame: CGRect) {
        self.file = file
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawTitle(text: file.name!)
        drawSize(text: StringUtils.suffixedFor(size: file.size))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupDownloadingState()
    func setupProgressView()
    func setupIcon()
    func drawTitle(text: String)
    func drawSize(text: String)
}

fileprivate protocol Configuration: class {
    func updateIconForCurrentState()
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
extension AttachmentFileView: Setup {
    func initialSetup() {
        self.backgroundColor = UIColor.clear
        self.setupIcon()
        self.setupProgressView()
        self.setupDownloadingState()
    }
    
    fileprivate func setupDownloadingState() {
        if file.downoloadedSize == file.size {
            self.downloadingState = DownloadingState.Downloaded
        } else {
            self.downloadingState = (file.downoloadedSize == 0) ? DownloadingState.NotDownloaded
                : DownloadingState.Downloading
        }
    }
    
    fileprivate func setupProgressView() {
        self.progressView.frame = CGRect(x: 12, y: 12, width: 30, height: 30)
        
        self.progressView.backgroundColor = UIColor.clear
        self.progressView.valueLabel.isHidden = true
        self.progressView.borderWidth = 0
        self.progressView.lineWidth = 2
        self.progressView.tintColor = ColorBucket.whiteColor
        self.progressView.isHidden = true
        self.addSubview(self.progressView)
    }
    
    fileprivate func setupIcon() {
        self.iconImageView.backgroundColor = UIColor.clear
        self.iconImageView.frame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        self.addSubview(self.iconImageView)
    }
    
    fileprivate func drawTitle(text: String) {
        let textColor = ColorBucket.blueColor
        let textFont =  UIFont.systemFont(ofSize: 13)
        let attributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
        let height = CGFloat(StringUtils.heightOfString(text, width: frame.width - 64, font: textFont))
        let nameFrame = CGRect(x: 54, y: 8, width: frame.width - 64, height: height).offsetBy(dx: 0, dy: frame.origin.y)
        (self.file.name! as NSString).draw(in: nameFrame, withAttributes: attributes)
    }
    
    fileprivate func drawSize(text: String) {
        let textColor = ColorBucket.rightMenuSeparatorColor
        let textFont = FontBucket.messageFont
        let attributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
        let y = 20 + CGFloat(StringUtils.heightOfString(text, width: frame.width - 64, font: textFont))
        let textFrame = CGRect(x: 54, y: y, width: frame.width - 64, height: 20).offsetBy(dx: 0, dy: frame.origin.y)
        (text as NSString).draw(in: textFrame, withAttributes: attributes)
    }
}


//MARK: Configuration
extension AttachmentFileView: Configuration {
    fileprivate func updateIconForCurrentState() {
        switch self.downloadingState {
        case DownloadingState.NotDownloaded:
            self.iconImageView.image = UIImage(named: "chat_notdownloaded_icon")
        case DownloadingState.Downloading:
            self.iconImageView.image = UIImage(named: "chat_downloading_icon")
        case DownloadingState.Downloaded:
            self.iconImageView.image = UIImage(named: "chat_downloaded_icon")
        default:
            break
        }
    }
}


//MARK: Action
extension AttachmentFileView: Action {
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


//MARK: Downloading
extension AttachmentFileView: Downloading {
    fileprivate func startDownloadingFile() {
        self.progressView.isHidden = false
        self.downloadingState = DownloadingState.Downloading
        let fileId = self.file.identifier
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            Api.sharedInstance.download(fileId: fileId!, completion: { (error) in
                self.progressView.isHidden = true
                guard error == nil else {
                    AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: UIViewController())
                    return
                }
                self.downloadingState = DownloadingState.Downloaded
                
                AlertManager.sharedManager.showSuccesWithMessage(message: "File was successfully downloaded" , viewController: UIViewController())
                
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
                                          object: nil, userInfo: ["fileId" : fileId])
        NotificationCenter.default.post(notification as Notification)
    }
}
