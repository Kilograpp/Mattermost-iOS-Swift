//
//  AttachmentFileCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 09/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AttachmentFileCell: UITableViewCell, Reusable, Attachable {
    private var file: File!
    
    func configureWithFile(file: File) {
        self.file = file
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let iconFrame = CGRectOffset(CGRectMake(5, 5, 44, 44), frame.origin.x, frame.origin.y)
        UIImage(named: "message_file_icon")?.drawInRect(iconFrame)
        
//        let nameFrame = CGRectOffset(CGRectMake(CGRectGetMaxX(iconFrame) + 5, 8, frame.size.width - 64, 20), 0, frame.origin.y);
//        (self.file.name as? NSString)?.drawInRect(nameFrame, withAttributes: )
//        withAttributes:self.fileNameAttributesCache];
    }
}

