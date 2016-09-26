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
    private let cancelButton: UIButton = UIButton()
    private let messageLabel: UILabel = UILabel()
    
    var actionType: String = ""
    
    class func compactPostView(type: String) -> CompactPostView {
        let compactPostView = CompactPostView()
        compactPostView.actionType = type
        compactPostView.initialSetup()
        
        return compactPostView
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
        if (self.actionType == ActionType.CompleteReply) {
            width -= (Constants.UI.FeedCellMessageLabelPaddings + Constants.UI.PostStatusViewSize)
        }
        return CGSizeMake(width, 64)
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
            setupCancelButton()
        }
        setupMessageLabel()
    }
    
    func setupBackground() {
        self.backgroundColor = (self.actionType != ActionType.CompleteReply) ? ColorBucket.editBackgroundColor : UIColor.whiteColor()
    }
    
    func setupContentView() {
        self.contentView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentBackgroundColor : UIColor.whiteColor()
        self.contentView.layer.shadowColor = ColorBucket.parentShadowColor.CGColor
        self.contentView.layer.shadowOpacity = 0.15
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1)
        self.contentView.layer.cornerRadius = 3.0
        let width = UIScreen.screenWidth() - 2 * Constants.UI.MiddlePaddingSize
        self.contentView.frame = CGRectMake(8, 10, width, 48)
        self.addSubview(self.contentView)
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentSeparatorColor : ColorBucket.editSeparatorColor
        self.contentView.addSubview(self.separatorView)
        self.separatorView.frame = CGRectMake(10, 5, 2, 38)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.backgroundColor = self.contentView.backgroundColor
        self.avatarImageView.frame = CGRectMake(20, 5, 16, 16)
        self.avatarImageView.layer.cornerRadius = 8
        self.contentView.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        self.nameLabel.backgroundColor = self.contentView.backgroundColor
        self.nameLabel.font = FontBucket.parentAuthorNameFont
        self.nameLabel.textColor = ColorBucket.parentAuthorColor
        let width = UIScreen.screenWidth() - 41 - 20
        self.nameLabel.frame = CGRectMake(41, 5, width, 16)
        self.contentView.addSubview(self.nameLabel)
    }
    
    func setupTypeLabel() {
        self.typeLabel.backgroundColor = self.contentView.backgroundColor
        self.typeLabel.font = FontBucket.editTypeFont
        self.typeLabel.textColor = ColorBucket.editSeparatorColor
        let width = UIScreen.screenWidth() - 20 - 45
        self.typeLabel.frame = CGRectMake(20, 10, width, 14)
        self.contentView.addSubview(self.typeLabel)
    }
    
    func setupCancelButton() {
        self.cancelButton.backgroundColor = self.contentView.backgroundColor
        self.cancelButton.setImage(UIImage(named: "close button"), forState: .Normal)
        let x = self.typeLabel.frame.origin.x + self.typeLabel.frame.size.width + 5
        self.cancelButton.frame = CGRectMake(x, 5, 16, 16)
        self.contentView.addSubview(self.cancelButton)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = self.contentView.backgroundColor
        self.messageLabel.font = (self.actionType == ActionType.CompleteReply) ? FontBucket.parentMessageFont : FontBucket.messageFont
        self.messageLabel.textColor = UIColor.blueColor()
        let width = UIScreen.screenWidth() - 20 - 20
        self.messageLabel.frame = CGRectMake(20, 28, width, 16)
        self.contentView.addSubview(self.messageLabel)
    }
}