//
//  PostAttachmentsViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PostAttachmentsViewCell : UICollectionViewCell {
    static let identifier = String(PostAttachmentsViewCell.self)
    static let itemSize = CGSizeMake(70, 70)
    
    var backgroundImageView : UIImageView?
    var removeButton : UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImage()
        setupremoveButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private protocol Private : class {
    func setupBackgroundImage()
    func setupremoveButton()
}

private protocol Public : class {
    func configureWithItem(item: AssignedPhotoViewItem)
}

extension PostAttachmentsViewCell : Private {
    private func setupBackgroundImage() {
        self.backgroundImageView = UIImageView(frame: self.bounds)
        self.backgroundImageView?.backgroundColor = ColorBucket.blueColor
        self.backgroundImageView?.layer.cornerRadius = 3
        self.addSubview(self.backgroundImageView!)
    }
    
    private func setupremoveButton() {
        
    }
}

extension PostAttachmentsViewCell : Public {
    func configureWithItem(item: AssignedPhotoViewItem) {
        self.backgroundImageView?.image = item.image
    }
}