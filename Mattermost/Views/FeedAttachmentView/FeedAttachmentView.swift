//
//  FeedAttachmentView.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 01.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class FeedAttachmentView: UIView {
    var file: File?
    var size: CGSize?
    let sizeForImage = CGSize(width: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings, height: 80)
    let sizeForFile = CGSize(width: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings, height: 40)
    
    init(file: File) {
        self.file = file
        self.size = file.isImage == true ? sizeForImage : sizeForFile
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = ColorBucket.whiteColor
    }
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let ref = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        context?.addPath(ref)
        context?.setFillColor(UIColor(white: 0.95, alpha: 1).cgColor)
        context?.fillPath()
//        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
        UIGraphicsEndImageContext()
    }
}

private protocol FeedAttachmentViewConfiguration : class {
    func configure()
}

private protocol Private : class {
    func configureForImageAttachment()
    func configureForFileAttachment()
}

//MARK: - Configuration
extension FeedAttachmentView : FeedAttachmentViewConfiguration {
    func configure() {
        if self.file!.isImage == true {
            self.configureForImageAttachment()
        } else {
            self.configureForFileAttachment()
        }
//        self.setNeedsDisplay()
    }
}

//MARK: - Private
extension FeedAttachmentView : Private {
    fileprivate func configureForImageAttachment() {
        
    }
    
    fileprivate func configureForFileAttachment() {
        
    }
}
