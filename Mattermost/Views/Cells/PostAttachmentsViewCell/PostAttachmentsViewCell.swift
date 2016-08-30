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
    var progressView : UIProgressView?
    var image: UIImage?
    
    var removeTapHandler : ((image: UIImage) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImage()
        setupremoveButton()
        setupProgressView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private protocol Private : class {
    func setupBackgroundImage()
    func setupremoveButton()
    func setupProgressView()
    
    func removeButtonAction()
}

private protocol Public : class {
    func configureWithItem(item: AssignedPhotoViewItem)
    func updateProgressViewWithValue(value: Float)
}

extension PostAttachmentsViewCell : Private {
    private func setupBackgroundImage() {
        self.backgroundImageView = UIImageView()
        self.backgroundImageView?.backgroundColor = ColorBucket.blueColor
        self.backgroundImageView?.layer.cornerRadius = 3
        self.backgroundImageView?.clipsToBounds = true
        self.addSubview(self.backgroundImageView!)
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 3)
        let right = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -3)
        let top = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 3)
        let bottom = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -3)
        self.addConstraints([left, right, top, bottom])
    }
    
    private func setupremoveButton() {
        self.removeButton = UIButton()
        self.addSubview(self.removeButton!)
        self.removeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.removeButton?.setImage(UIImage(named: "close"), forState: .Normal)
        let left = NSLayoutConstraint(item: self.removeButton!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.removeButton!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self.removeButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 12)
        let bottom = NSLayoutConstraint(item: self.removeButton!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 12)
        self.addConstraints([left, right, height, bottom])
        
        self.removeButton?.addTarget(self, action: #selector(removeButtonAction), forControlEvents: .TouchUpInside)
    }
    
    private func setupProgressView() {
        self.progressView = UIProgressView()
        self.progressView?.progress = 0.4
        self.progressView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.progressView!)
        let left = NSLayoutConstraint(item: self.progressView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 8)
        let right = NSLayoutConstraint(item: self.progressView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -8)
        let height = NSLayoutConstraint(item: self.progressView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 2)
        let bottom = NSLayoutConstraint(item: self.progressView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -8)
        self.addConstraints([left, right, height, bottom])

    }
    
    @objc private func removeButtonAction() {
        self.removeTapHandler!(image: self.image!)
    }
}

extension PostAttachmentsViewCell : Public {
    func configureWithItem(item: AssignedPhotoViewItem) {
        self.image = item.image
        self.backgroundImageView?.image = item.image
    }
    
    func updateProgressViewWithValue(value: Float) {
        self.progressView?.progress = value
        guard value != 1 else {
            self.progressView?.hidden = true
            return
        }
    }
}