//
//  PostAttachmentsViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PostAttachmentsViewCell : UICollectionViewCell {
    static let identifier = String(describing: PostAttachmentsViewCell.self)
    static let itemSize = CGSize(width: 70, height: 70)
    
    fileprivate var backgroundImageView : UIImageView?
    fileprivate var removeButton : UIButton?
    fileprivate var progressView : UIProgressView?
    fileprivate var imageItem: AssignedPhotoViewItem?
    
    var removeTapHandler : ((_ image: AssignedPhotoViewItem) -> Void)?
    var index: Int?
    
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
    func configureWithItem(_ item: AssignedPhotoViewItem)
    func updateProgressViewWithValue(_ value: Float)
}

extension PostAttachmentsViewCell : Private {
    fileprivate func setupBackgroundImage() {
        self.backgroundImageView = UIImageView()
        self.backgroundImageView?.backgroundColor = ColorBucket.blueColor
        self.backgroundImageView?.layer.cornerRadius = 3
        self.backgroundImageView?.clipsToBounds = true
        self.backgroundImageView?.contentMode = .scaleAspectFill
        self.addSubview(self.backgroundImageView!)
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 3)
        let right = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -3)
        let top = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 3)
        let bottom = NSLayoutConstraint(item: self.backgroundImageView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -3)
        self.addConstraints([left, right, top, bottom])
    }
    
    fileprivate func setupremoveButton() {
        self.removeButton = UIButton()
        self.addSubview(self.removeButton!)
        self.removeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.removeButton?.setBackgroundImage(UIImage(named: "close"), for: UIControlState())
        let left = NSLayoutConstraint(item: self.removeButton!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.removeButton!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self.removeButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 25)
        let bottom = NSLayoutConstraint(item: self.removeButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 25)
        self.addConstraints([left, right, height, bottom])
        
        self.removeButton?.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setupProgressView() {
        self.progressView = UIProgressView()
        self.progressView?.progress = 0
        self.progressView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.progressView!)
        let left = NSLayoutConstraint(item: self.progressView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 8)
        let right = NSLayoutConstraint(item: self.progressView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -8)
        let height = NSLayoutConstraint(item: self.progressView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 2)
        let bottom = NSLayoutConstraint(item: self.progressView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -8)
        self.addConstraints([left, right, height, bottom])

    }
    
    @objc fileprivate func removeButtonAction() {
        self.removeTapHandler!(self.imageItem!)
    }
}

extension PostAttachmentsViewCell : Public {
    func configureWithItem(_ item: AssignedPhotoViewItem) {
        self.imageItem = item
        self.backgroundImageView?.image = item.image
        self.progressView?.isHidden = item.uploaded
    }
    
    func updateProgressViewWithValue(_ value: Float) {
        self.progressView?.progress = value
        self.progressView?.isHidden = value == 1
    }
}
