//
//  CompactPostView.swift
//  Mattermost
//
//  Created by TaHyKu on 25.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

let BaseHeight = CGFloat(64)
let ContentHeight = CGFloat(48)
let SeparatorSize = CGSizeMake(2, 38)

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

private protocol Action {
    func cancelAction()
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
    
    var cancelHandler : (() -> Void)?
    
    var actionType: String = ""
    
    class func compactPostView(type: String) -> CompactPostView {
        let compactPostView = CompactPostView()
        compactPostView.actionType = type
        compactPostView.initialSetup()
        
        return compactPostView
    }
    
    func configureWithCompletePost(post: Post) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(post.author) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        self.nameLabel.text = post.author.displayName
        self.messageLabel.text = post.message
    }
    
    func configureWithPost(post: Post, action: String) {
        self.typeLabel.text = (action == ActionType.Edit) ? "Edit message" : "Reply message"
        self.messageLabel.text = post.message
    }
    
    func requeredSize() -> CGSize {
        var width = UIScreen.screenWidth()
        if (self.actionType == ActionType.CompleteReply) {
            width -= (Constants.UI.FeedCellMessageLabelPaddings + Constants.UI.PostStatusViewSize)
        }
        return CGSizeMake(width, BaseHeight)
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
        let width = UIScreen.screenWidth() - Constants.UI.StandardPaddingSize
        self.contentView.frame = CGRectMake(Constants.UI.MiddlePaddingSize, Constants.UI.LongPaddingSize, width, ContentHeight)
        self.addSubview(self.contentView)
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentSeparatorColor : ColorBucket.editSeparatorColor
        self.contentView.addSubview(self.separatorView)
        self.separatorView.frame = CGRectMake(Constants.UI.LongPaddingSize, Constants.UI.ShortPaddingSize, SeparatorSize.width, SeparatorSize.height)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.backgroundColor = self.contentView.backgroundColor
        self.avatarImageView.frame = CGRectMake(Constants.UI.DoublePaddingSize, Constants.UI.ShortPaddingSize,
                                                Constants.UI.StandardPaddingSize, Constants.UI.StandardPaddingSize)
        self.avatarImageView.layer.cornerRadius = Constants.UI.MiddlePaddingSize
        self.contentView.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        self.nameLabel.backgroundColor = self.contentView.backgroundColor
        self.nameLabel.font = FontBucket.parentAuthorNameFont
        self.nameLabel.textColor = ColorBucket.parentAuthorColor
        let originX = Constants.UI.DoublePaddingSize + Constants.UI.StandardPaddingSize + Constants.UI.ShortPaddingSize
        let width = UIScreen.screenWidth() - (originX + Constants.UI.DoublePaddingSize)
        self.nameLabel.frame = CGRectMake(originX, Constants.UI.ShortPaddingSize, width, Constants.UI.StandardPaddingSize)
        self.contentView.addSubview(self.nameLabel)
    }
    
    func setupTypeLabel() {
        self.typeLabel.backgroundColor = self.contentView.backgroundColor
        self.typeLabel.font = FontBucket.editTypeFont
        self.typeLabel.textColor = ColorBucket.editSeparatorColor
        let width = UIScreen.screenWidth() - (3 * Constants.UI.DoublePaddingSize + Constants.UI.ShortPaddingSize)
        self.typeLabel.frame = CGRectMake(Constants.UI.DoublePaddingSize, Constants.UI.LongPaddingSize, width, 14)
        self.contentView.addSubview(self.typeLabel)
    }
    
    func setupCancelButton() {
        self.cancelButton.backgroundColor = self.contentView.backgroundColor
        self.cancelButton.setImage(UIImage(named: "close button"), forState: .Normal)
        let x = self.typeLabel.frame.origin.x + self.typeLabel.frame.size.width + Constants.UI.ShortPaddingSize
        self.cancelButton.frame = CGRectMake(x, Constants.UI.ShortPaddingSize, Constants.UI.StandardPaddingSize, Constants.UI.StandardPaddingSize)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        self.contentView.addSubview(self.cancelButton)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = self.contentView.backgroundColor
        self.messageLabel.font = (self.actionType == ActionType.CompleteReply) ? FontBucket.parentMessageFont : FontBucket.messageFont
        self.messageLabel.textColor = ColorBucket.parentMessageColor
        let width = UIScreen.screenWidth() - 2 * Constants.UI.DoublePaddingSize
        self.messageLabel.frame = CGRectMake(Constants.UI.DoublePaddingSize, Constants.UI.DoublePaddingSize + Constants.UI.MiddlePaddingSize, width, Constants.UI.StandardPaddingSize)
        self.contentView.addSubview(self.messageLabel)
    }
}


//MARK: Action

extension CompactPostView: Action {
    func cancelAction() {
        self.cancelHandler!()
    }
}