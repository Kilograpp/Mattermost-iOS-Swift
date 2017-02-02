//
//  AttachmentFileCell.swift
//  Mattermost
//
//  Created by Maxim Gubin on 09/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol AttachmentFileCellConfiguration: class {
    func configureWithFile(_ file: File)
}

final class AttachmentFileCell: UITableViewCell, Reusable, Attachable {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        fileView = AttachmentFileView(frame: self.bounds)
        contentView.addSubview(fileView)
        
   //     fileView = AttachmentFileView(file: file, frame: self.bounds)
   //     contentView.addSubview(fileView)
        self.backgroundColor = UIColor.white

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: Properties
    fileprivate var file: File!{
        didSet {
            //fileView.setNeedsDisplay()

        }
    }
    fileprivate var fileView: AttachmentFileView!
    
//MARK: LifeCycle
//    override func prepareForReuse() {
//        fileView.removeFromSuperview()
//        fileView = nil
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


//MARK: AttachmentFileCellConfiguration
extension AttachmentFileCell: AttachmentFileCellConfiguration {
    func configureWithFile(_ file: File) {
        self.file = file
        self.fileView.configureWith(file: file)
        //TEMP TODO: files uploading
        self.selectionStyle = .none
//        self.setNeedsDisplay()
    }
}
