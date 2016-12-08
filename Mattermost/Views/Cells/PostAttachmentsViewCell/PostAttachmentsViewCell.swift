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
    
    var backgroundImageView : UIImageView?
    fileprivate var removeButton : UIButton?
    fileprivate var progressView : UIProgressView?
    fileprivate var imageItem: AssignedAttachmentViewItem?
    
    var removeTapHandler : ((_ image: AssignedAttachmentViewItem) -> Void)?
    var index: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImage()
        setupRemoveButton()
        setupProgressView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithItem(_ item: AssignedAttachmentViewItem) {
        self.progressView?.isHidden = item.uploaded
        self.imageItem = item
        self.backgroundImageView?.image = imageItem?.image
    }
    
    func updateProgressViewWithValue(_ value: Float) {
        self.progressView?.progress = value
        self.progressView?.isHidden = value == 1
        if value == 1 {
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activity.tag = 77
            activity.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            activity.startAnimating()
            self.addSubview(activity)
        }
    }
}

public protocol PrivatePostAttachmentsViewCell : class {
    func setupBackgroundImage()
    func setupRemoveButton()
    func setupProgressView()
    
    func removeButtonAction()
}

public protocol PublicPostAttachmentsViewCell : class {
    func updateProgressViewWithValue(_ value: Float)
}

extension PostAttachmentsViewCell : PrivatePostAttachmentsViewCell {
    func setupBackgroundImage() {
        self.backgroundImageView = UIImageView()
        //self.backgroundImageView?.backgroundColor = ColorBucket.blueColor
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
    
    func setupRemoveButton() {
        self.removeButton = UIButton()
        self.addSubview(self.removeButton!)
        self.removeButton?.translatesAutoresizingMaskIntoConstraints = false
        self.removeButton?.setBackgroundImage(UIImage(named: "attach_delete_icon"), for: UIControlState())
        let left = NSLayoutConstraint(item: self.removeButton!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.removeButton!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self.removeButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 23)
        let bottom = NSLayoutConstraint(item: self.removeButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 23)
        self.addConstraints([left, right, height, bottom])
        
        self.removeButton?.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    func setupProgressView() {
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
    
    @objc func removeButtonAction() {
        self.removeTapHandler!(self.imageItem!)
    }
}

extension PostAttachmentsViewCell : PublicPostAttachmentsViewCell {
    
}
