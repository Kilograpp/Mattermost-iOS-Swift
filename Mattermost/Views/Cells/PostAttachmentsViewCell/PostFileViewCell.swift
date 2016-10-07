//
//  PostFileViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class PostFileViewCell: PostAttachmentsViewCell {
    let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    override func configureWithItem(_ item: AssignedPhotoViewItem) {
        super.configureWithItem(item)
        
        self.nameLabel.text = item.fileName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.nameLabel.frame = CGRect(x: 0, y: self.bounds.height/2 - 10, width: self.bounds.width, height: 20)
    }
}

private protocol Setup {
    func setupLabel()
}

extension PostFileViewCell: Setup {
    func setupLabel() {
        self.backgroundImageView?.backgroundColor = UIColor.clear
        self.nameLabel.font = UIFont.systemFont(ofSize: 14)
        self.nameLabel.textColor = UIColor.black
        self.addSubview(self.nameLabel)
        self.bringSubview(toFront: nameLabel)
    }
}
