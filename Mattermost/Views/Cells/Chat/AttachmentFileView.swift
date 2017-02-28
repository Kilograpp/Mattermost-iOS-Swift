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


//Temp solution
let supportedFileTypes = [ "txt", "pdf", "doc", "gif", "ppt", "pptx", "docx", "xls", "xlsx", "mov", "mp3", "zip", "mp4" ] //TODO: add others

fileprivate struct DownloadingState {
    static let NotDownloaded: Int = 0
    static let Downloading: Int   = 1
    static let Downloaded: Int    = 2
}

fileprivate protocol Interface: class {
    func configureWith(file: File)
}

class AttachmentFileView: UIView {
    static let NotDownloadedFileIcon       = UIImage(named: "chat_notdownloaded_icon")
    static let DownloadedFileIcon          = UIImage(named: "chat_downloaded_icon")
    static let FileDownloadingProgressIcon = UIImage(named: "chat_downloading_icon")
    
    static let fileSizeFont = UIFont.systemFont(ofSize: 13)
    
//MARK: Properties
    let iconImageView = UIImageView()
    let progressView = MRCircularProgressView()
    var file: File!
    
    var tapHandler: (() -> Void)?
    
    var downloadingState: Int = DownloadingState.NotDownloaded {
        didSet { updateIconForCurrentState() }
    }

//MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard self.file.name != nil else { return }
        
        drawTitle(text: self.file.name!)
        drawSize(text: StringUtils.suffixedFor(size: file.size))
    }
}


extension AttachmentFileView: Interface {
    func configureWith(file: File) {
        self.file = file
        
        self.iconImageView.image = AttachmentFileView.NotDownloadedFileIcon
        self.setNeedsDisplay()
        configureDownloadingState()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupIcon()
    func setupProgressView()
    func setupGestureRecognizers()
}

fileprivate protocol AttachmentFileViewConfiguration: class {
    func updateIconForCurrentState()
    func configureDownloadingState()
    func drawTitle(text: String)
    func drawSize(text: String)
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
        // was UIColor.clear
        self.backgroundColor = UIColor.white
        setupIcon()
        setupProgressView()
        setupGestureRecognizers()
    }
    
    fileprivate func setupIcon() {
        self.iconImageView.backgroundColor = UIColor.white
        self.iconImageView.frame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        self.iconImageView.layer.cornerRadius = 22.0
        self.iconImageView.clipsToBounds = true

        self.addSubview(self.iconImageView)
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
    
    fileprivate func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}


//MARK: AttachmentFileViewConfiguration
extension AttachmentFileView: AttachmentFileViewConfiguration {
    fileprivate func updateIconForCurrentState() {
        switch self.downloadingState {
        case DownloadingState.NotDownloaded:
            self.iconImageView.image = AttachmentFileView.NotDownloadedFileIcon
        case DownloadingState.Downloading:
            self.iconImageView.image = AttachmentFileView.FileDownloadingProgressIcon
        case DownloadingState.Downloaded:
            self.iconImageView.image = AttachmentFileView.DownloadedFileIcon
        default:
            break
        }
    }
    
    fileprivate func configureDownloadingState() {
        if (file.downoloadedSize == file.size) && (file.size != 0) {
            self.downloadingState = DownloadingState.Downloaded
        } else {
            self.downloadingState = (file.downoloadedSize == 0) ? DownloadingState.NotDownloaded
                : DownloadingState.Downloading
        }
    }
    
    fileprivate func drawTitle(text: String) {
        var fileName = self.file.name!
        let textColor = ColorBucket.blueColor
        let textFont =  AttachmentFileView.fileSizeFont
        let attributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
        
        if fileName.characters.count > 24 {
            let name = (fileName as NSString).deletingPathExtension.substring(to: fileName.index(fileName.startIndex, offsetBy: 16))
            let ext = (fileName as NSString).pathExtension
            fileName = name + "..." + ext
        }
        let nameFrame = CGRect(x: 54, y: 8, width: frame.width - 64, height: 30).offsetBy(dx: 0, dy: frame.origin.y)
        fileName.draw(in: nameFrame, withAttributes: attributes)
    }
    
    fileprivate func drawSize(text: String) {
        let attributes = [NSFontAttributeName: FontBucket.messageFont,
                          NSForegroundColorAttributeName: ColorBucket.rightMenuSeparatorColor,
                          NSBackgroundColorAttributeName: self.backgroundColor!] as [String : Any]
        let textFrame = CGRect(x: 54, y: 28, width: frame.width - 64, height: 24).offsetBy(dx: 0, dy: frame.origin.y)
        (text as NSString).draw(in: textFrame, withAttributes: attributes)
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
        self.progressView.setProgress(0.05, animated: true)
        self.downloadingState = DownloadingState.Downloading
        let fileId = self.file.identifier
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async(execute: {
            Api.sharedInstance.download(fileId: fileId!, completion: { (error) in
                self.progressView.isHidden = true
                guard error == nil else {
                    AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                    return
                }
                self.downloadingState = DownloadingState.Downloaded
                
                AlertManager.sharedManager.showFileDownloadedAlert(fileIdentifier: self.file.identifier!, canBeOpenned: self.canOpenFilePreview(fileId: self.file.identifier!), tapHandler: AttachmentFileView.openDownloadedFileByIdentifier)
            }) { (identifier, progress) in
                if fileId == identifier {
                    self.progressView.progress = max(progress, 0.05)
                }
            }
        })
    }
    
    fileprivate func canOpenFilePreview(fileId: String) -> Bool {
        let file = RealmUtils.realmForCurrentThread().object(ofType: File.self, forPrimaryKey: fileId)
//        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + (file?.name)!
//
//        let documentInteractionController = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
//        return documentInteractionController.presentOpenInMenu(from: .zero, in: UIView(), animated: false)
        return supportedFileTypes.contains(file!.ext!.lowercased())
    }
    
    fileprivate func stopDownloadingFile() {
        self.downloadingState = DownloadingState.NotDownloaded
        self.progressView.isHidden = true
        Api.sharedInstance.cancelDownloading(fileId: self.file.identifier!)
    }
    
    fileprivate static func openDownloadedFileByIdentifier(identifier: String) {
        let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.DocumentInteractionNotification),
                                        object: nil, userInfo: ["fileId" : identifier])
        NotificationCenter.default.post(notification as Notification)
    }
    
    fileprivate func openDownloadedFile() {
        let fileId = self.file.identifier
        let notification = Notification(name: NSNotification.Name(Constants.NotificationsNames.DocumentInteractionNotification),
                                          object: nil, userInfo: ["fileId" : fileId!])
        NotificationCenter.default.post(notification as Notification)
    }
}
