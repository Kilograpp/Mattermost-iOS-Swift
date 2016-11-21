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

class AttachmentFileView: UIView {
    let iconImageView = UIImageView()
    let progressView = MRCircularProgressView()
    var file: File!
    
    var tapHandler: (() -> Void)?
    
    init(file: File, frame: CGRect) {
        self.file = file
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setupIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if file.downoloadedSize == file.size {
            self.iconImageView.image = UIImage(named: "chat_downloaded_icon")
        } else {
            let name = (file.downoloadedSize == 0) ? "chat_notdownloaded_icon" : "chat_downloading_icon"
            self.iconImageView.image = UIImage(named: name)
        }
        drawTitle(text: file.name!)
        drawSize(text: StringUtils.suffixedFor(size: file.size))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func tapAction() {
        self.iconImageView.image = UIImage(named: "chat_downloading_icon")
        showProgressView()
    }
    
    fileprivate func showProgressView() {
        self.progressView.frame = CGRect(x: 12, y: 12, width: 30, height: 30)
        
        self.progressView.backgroundColor = UIColor.clear
        self.progressView.valueLabel.isHidden = true
        self.progressView.borderWidth = 0
        self.progressView.lineWidth = 2
        self.progressView.tintColor = ColorBucket.whiteColor
        
        self.addSubview(self.progressView)
        self.progressView.setProgress(0.05, animated: true)
        
   /*     DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            self.capWork()
            DispatchQueue.main.sync(execute: {
                    self.progressView.removeFromSuperview()
                  })
        }*/
    }
    
    fileprivate func capWork() {
        var progress: Float = 0
        while progress < Float(1) {
            progress += 0.01
            DispatchQueue.main.sync(execute: {
                self.progressView.progress = progress
            })
            usleep(50000);
        }
    }
}


extension AttachmentFileView {
    fileprivate func startDownloadingFile() {
    
    }
    
    fileprivate func stopDownloadingFile() {
    
    }
    
    fileprivate func openDownloadedFile() {
    
    }
}


extension AttachmentFileView {
    fileprivate func setupIcon() {
        self.iconImageView.backgroundColor = UIColor.clear
        self.iconImageView.frame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        self.addSubview(self.iconImageView)
    }
    
    fileprivate func drawIconWith(name: String) {
 //       let iconFrame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        //UIImage(named: name)?.draw(in: iconFrame)
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
