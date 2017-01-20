//
//  PostFileViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PostFileViewCell: PostAttachmentsViewBaseCell {
    let formatLabel = UILabel()
    let titleLabel = UILabel()
    
//MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view = UIView(frame: CGRect(x: 5, y: 5, width: PostAttachmentsViewBaseCell.itemSize.width - 10, height: PostAttachmentsViewBaseCell.itemSize.height - 10))
        view.backgroundColor = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
//        addSubview(view)
        insertSubview(view, belowSubview: removeButton)
        setupLabel()
    }
    
    override func configureWithItem(_ item: AssignedAttachmentViewItem) {
        super.configureWithItem(item)
        self.clipsToBounds = true
        
        guard item.isFile else {
            self.formatLabel.text = ""
            self.titleLabel.text = ""
            return
        }
        self.formatLabel.text = self.fileTypeString(fileNameString: item.fileName!)
        self.titleLabel.text = item.fileName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.formatLabel.frame = CGRect(x: 10, y: 17, width: 50, height: 16)
        self.titleLabel.frame = CGRect(x: 10, y: 31, width: 50, height: 25)
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
//        backgroundColor = UIColor.yellow
        self.formatLabel.font = FontBucket.semiboldFontOfSize(15)
        self.formatLabel.textColor = UIColor.gray
        self.formatLabel.textAlignment = NSTextAlignment.center
        self.addSubview(self.formatLabel)
        
        self.titleLabel.font = FontBucket.regularFontOfSize(10)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.numberOfLines = 2;
        self.addSubview(self.titleLabel)

        self.formatLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.titleLabel.textAlignment = NSTextAlignment.center
    }
}
