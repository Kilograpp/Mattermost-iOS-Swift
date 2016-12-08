//
//  PostFileViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SnapKit

class PostFileViewCell: PostAttachmentsViewCell {
    let nameLabel = UILabel()//(frame: CGRect(x: 5, y: 0, width: 65, height: 0))
    let fileLabel = UILabel()//(frame: CGRect(x: 5, y: 0, width: 65, height: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    override func configureWithItem(_ item: AssignedAttachmentViewItem) {
        super.configureWithItem(item)
        
        self.clipsToBounds = true
        self.nameLabel.text = item.fileName
       
        self.fileLabel.text = self.fileTypeString(fileNameString: item.fileName!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.nameLabel.frame = CGRect(x: 3, y: 40, width: 63, height: self.nameLabel.frame.height)
        self.fileLabel.frame = CGRect(x: 3, y: 15, width: 63, height: self.fileLabel.frame.height)
    }
    
    func fileTypeString(fileNameString: String) -> String {
        var fileName = fileNameString
        var fileType = " "
        var flag = true
        while flag {
            if (fileName[fileName.index(before: fileName.endIndex)] == ".") {
                flag = false
                fileType.insert(fileName[fileName.index(before: fileName.endIndex)], at: fileType.startIndex)
            }else{
                fileType.insert(fileName[fileName.index(before: fileName.endIndex)], at:  fileType.startIndex)
                fileName.remove(at: fileName.index(before: fileName.endIndex))
            }
        }
        fileType.remove(at: fileType.index(before: fileType.endIndex))
        return fileType
    }
}

private protocol Setup {
    func setupLabel()
}

extension PostFileViewCell: Setup {
    func setupLabel() {
        let nameLabelView = UIView()
        self.addSubview(nameLabelView)
        self.backgroundImageView?.backgroundColor = UIColor.clear
        self.nameLabel.font = UIFont.systemFont(ofSize: 12)
        self.nameLabel.textColor = UIColor.black
        nameLabelView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(38)
            make.left.equalTo(self).offset(3)
            make.bottom.equalTo(self).offset(-10)
            make.right.equalTo(self).offset(-3)
        }
        self.nameLabel.textAlignment = NSTextAlignment.center
        
        let fileLabelView = UIView()
        self.addSubview(fileLabelView)
        self.fileLabel.font = UIFont.systemFont(ofSize: 19)
        self.fileLabel.textColor = UIColor.black
        fileLabelView.addSubview(self.fileLabel)
        self.fileLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(25)
            make.left.equalTo(self).offset(3)
            make.bottom.equalTo(self).offset(-20)
            make.right.equalTo(self).offset(-3)
        }
        self.nameLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.fileLabel.textAlignment = NSTextAlignment.center
    }
}
