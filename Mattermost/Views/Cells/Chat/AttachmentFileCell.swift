//
//  AttachmentFileCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 09/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AttachmentFileCell: UITableViewCell, Reusable, Attachable {
    fileprivate var file: File!
    
    func configureWithFile(_ file: File) {
        self.file = file
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let iconFrame = CGRect(x: 5, y: 5, width: 44, height: 44).offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        UIImage(named: "message_file_icon")?.draw(in: iconFrame)
        

        let nameFrame = CGRect(x: iconFrame.maxX + 5, y: 8, width: frame.width - 64, height: 20).offsetBy(dx: 0, dy: frame.origin.y)
        (self.file.name! as NSString).draw(in: nameFrame, withAttributes: nil)
        
//        let nameFrame = CGRectOffset(CGRectMake(iconFrame.maxX + 5, 8, frame.size.width - 64, 20), 0, frame.origin.y)
//        (self.file.name as? NSString)?.drawInRect(nameFrame, withAttributes: )
//        withAttributes:self.fileNameAttributesCache];
    }
}

