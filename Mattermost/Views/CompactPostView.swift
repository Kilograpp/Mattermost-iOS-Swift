//
//  CompactPostView.swift
//  Mattermost
//
//  Created by TaHyKu on 25.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct ActionType {
    static let Edit = "edit"
    static let Reply = "reply"
    static let CompleteReply = "completeReply"
}

private protocol Setup {
    func initialSetup()
    func setupBackground()
    func setupContentView()
    func setupSeparatorView()
    func setupAvatarImageView()
    func setupNameLabel()
    func setupTypeLabel()
    func setupMessageLabel()
}

class CompactPostView: UIView {

//Properties
    private let contentView: UIView = UIView()
    private let separatorView: UIView = UIView()
    private let avatarImageView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    private let typeLabel: UILabel = UILabel()
    private let messageLabel : UILabel = UILabel()
    
    var actionType: String = ""
    
    class func compactPostView(type: String) -> CompactPostView {
        let compactPostView = CompactPostView()
        compactPostView.actionType = type
        compactPostView.initialSetup()
        
        return UIView() as! CompactPostView
    }
    
    func configureWithPost(post: Post) {
        if (self.actionType == ActionType.CompleteReply) {
            self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
            ImageDownloader.downloadFeedAvatarForUser(post.author) { [weak self] (image, error) in
                self?.avatarImageView.image = image
            }
            self.nameLabel.text = post.author.displayName
        }
        else {
            self.typeLabel.text = (self.actionType == ActionType.Edit) ? "Edit message" : "Reply message"
        }
        self.messageLabel.text = post.message
    }
    
    func requeredSize() -> CGSize {
        var width = UIScreen.screenWidth()

        if (self.actionType != ActionType.CompleteReply) {
            width -= (Constants.UI.FeedCellMessageLabelPaddings + Constants.UI.PostStatusViewSize)
        }
        return CGSizeMake(width, 60)
    }
}


//MARK: Setup

extension CompactPostView: Setup {
    func initialSetup() {
        setupBackground()
        setupContentView()
        setupSeparatorView()
        if (self.actionType == ActionType.CompleteReply) {
            setupAvatarImageView()
            setupNameLabel()
        }
        else {
            setupTypeLabel()
        }
        setupMessageLabel()
    }
    
    func setupBackground() {
        self.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.editBackgroundColor : UIColor.whiteColor()
    }
    
    func setupContentView() {
        self.contentView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentBackgroundColor : UIColor.whiteColor()
        self.contentView.layer.shadowColor = ColorBucket.parentShadowColor.CGColor
        self.contentView.layer.shadowOpacity = 0.15
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        
        let leftConstant: CGFloat = (self.actionType == ActionType.CompleteReply) ? 60.0 : 8.0
        let rightConstant: CGFloat = (self.actionType == ActionType.CompleteReply) ? 15 : 8
        let left = NSLayoutConstraint(item: self.contentView, attribute: .Left,
                                      relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: leftConstant)
        let right = NSLayoutConstraint(item: self.contentView, attribute: .Right,
                                       relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: rightConstant)
        let top = NSLayoutConstraint(item: self.contentView, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 8)
        let bottom = NSLayoutConstraint(item: self.contentView, attribute: .Bottom,
                                        relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 8)
        self.addConstraints([left, right, top, bottom])
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentSeparatorColor : ColorBucket.editSeparatorColor
        self.contentView.addSubview(self.separatorView)
        
        let left = NSLayoutConstraint(item: self.separatorView, attribute: .Left,
                                      relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
        let top = NSLayoutConstraint(item: self.separatorView, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        let width = NSLayoutConstraint(item: self.separatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 2)
        let height = NSLayoutConstraint(item: self.separatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 40)
        self.addConstraints([left, top, width, height])
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.backgroundColor = self.contentView.backgroundColor
        self.avatarImageView.layer.cornerRadius = 8
        self.contentView.addSubview(self.avatarImageView)
        
        let left = NSLayoutConstraint(item: self.avatarImageView, attribute: .Left,
                                      relatedBy: .Equal, toItem: self.separatorView, attribute: .Left, multiplier: 1, constant: 8)
        let top = NSLayoutConstraint(item: self.avatarImageView, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        let width = NSLayoutConstraint(item: self.avatarImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 16)
        let height = NSLayoutConstraint(item: self.avatarImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 16)
        self.addConstraints([left, top, width, height])
    }
    
    func setupNameLabel() {
        self.nameLabel.backgroundColor = self.contentView.backgroundColor
        self.nameLabel.font = FontBucket.parentAuthorNameFont
        self.nameLabel.textColor = ColorBucket.parentAuthorColor
        self.contentView.addSubview(self.nameLabel)
        
        let left = NSLayoutConstraint(item: self.nameLabel, attribute: .Left,
                                      relatedBy: .Equal, toItem: self.avatarImageView, attribute: .Left, multiplier: 1, constant: 5)
        let top = NSLayoutConstraint(item: self.nameLabel, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        self.addConstraints([left, top])
    }
    
    func setupTypeLabel() {
        self.typeLabel.backgroundColor = self.contentView.backgroundColor
        self.typeLabel.font = FontBucket.editTypeFont
        self.typeLabel.textColor = ColorBucket.editSeparatorColor
        self.contentView.addSubview(self.typeLabel)
        
        let left = NSLayoutConstraint(item: self.typeLabel, attribute: .Left,
                                      relatedBy: .Equal, toItem: self.separatorView, attribute: .Left, multiplier: 1, constant: 8)
        let top = NSLayoutConstraint(item: self.typeLabel, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        self.addConstraints([left, top])
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = self.contentView.backgroundColor
        self.messageLabel.font = (self.actionType == ActionType.CompleteReply) ? FontBucket.parentMessageFont : FontBucket.messageFont
        self.messageLabel.textColor = UIColor.blueColor()
        self.contentView.addSubview(self.messageLabel)
        
        let left = NSLayoutConstraint(item: self.messageLabel, attribute: .Left,
                                      relatedBy: .Equal, toItem: self.separatorView, attribute: .Left, multiplier: 1, constant: 8)
        let top = NSLayoutConstraint(item: self.messageLabel, attribute: .Top,
                                     relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 32)
        let right = NSLayoutConstraint(item: self.messageLabel, attribute: .Right,
                                       relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1, constant: 10)
        
        self.addConstraints([left, top, right])
    }
}