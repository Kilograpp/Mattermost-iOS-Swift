//
//  AttachmentFileView.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 14.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class AttachmentFileView: UIView {
    var file: File!
    
    init(file: File, frame: CGRect) {
        self.file = file
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let iconFrame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        UIImage(named: "message_file_icon")?.draw(in: iconFrame)
        
        let textColor = ColorBucket.blueColor
        let textFont =  UIFont.systemFont(ofSize: 13)
        let attributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
        let nameFrame = CGRect(x: iconFrame.maxX + 5, y: 8, width: frame.width - 64, height: 20).offsetBy(dx: 0, dy: frame.origin.y)
        (self.file.name! as NSString).draw(in: nameFrame, withAttributes: attributes)
    }
}
