//
//  PostFileViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class PostFileViewCell: PostAttachmentsViewCell {
    let nameLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 65, height: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    override func configureWithItem(_ item: AssignedAttachmentViewItem) {
        super.configureWithItem(item)
        
        self.nameLabel.text = item.fileName
        self.nameLabel.numberOfLines = 1
        self.nameLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.nameLabel.frame = CGRect(x: 5, y: 25, width: 65, height: self.nameLabel.frame.height)
        
        super.layoutSubviews()
    }
}

private protocol Setup {
    func setupLabel()
}

extension PostFileViewCell: Setup {
    func setupLabel() {
        self.backgroundImageView?.backgroundColor = UIColor.clear
        self.nameLabel.font = UIFont.systemFont(ofSize: 13)
        self.nameLabel.textColor = UIColor.black
        self.addSubview(self.nameLabel)
        self.bringSubview(toFront: nameLabel)
    }
}
