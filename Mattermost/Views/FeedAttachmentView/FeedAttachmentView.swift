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
    let sizeForImage = CGSizeMake(UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings, 80)
    let sizeForFile = CGSizeMake(UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings, 40)
    
    init(file: File) {
        self.file = file
        self.size = file.isImage == true ? sizeForImage : sizeForFile
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = ColorBucket.whiteColor
    }
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let ref = UIBezierPath(roundedRect: rect, cornerRadius: 10).CGPath
        CGContextAddPath(context, ref);
        CGContextSetFillColorWithColor(context, UIColor.init(white: 0.95, alpha: 1).CGColor);
        CGContextFillPath(context);
//        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage;
        UIGraphicsEndImageContext();
    }
}

private protocol Configuration : class {
    func configure()
}

private protocol Private : class {
    func configureForImageAttachment()
    func configureForFileAttachment()
}

//MARK: - Configuration
extension FeedAttachmentView : Configuration {
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
    private func configureForImageAttachment() {
        
    }
    
    private func configureForFileAttachment() {
        
    }
}