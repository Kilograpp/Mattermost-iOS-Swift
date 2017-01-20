//
//  CompactPostView.swift
//  Mattermost
//
//  Created by TaHyKu on 25.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import QuartzCore

let BaseHeight = CGFloat(64)
let ContentHeight = CGFloat(48)
let SeparatorSize = CGSize(width: 2, height: 38)

struct ActionType {
    static let Edit = "edit"
    static let Reply = "reply"
    static let CompleteReply = "completeReply"
}

private protocol Interface: class {
    func configureWithCompletePost(_ post: Post)
    func configureWithPost(_ post: Post, action: String)
    func requeredSize() -> CGSize
}


class CompactPostView: UIView {

//MARK: Properties
    fileprivate let contentView: UIView = UIView()
    fileprivate let separatorView: UIView = UIView()
    fileprivate let avatarImageView: UIImageView = UIImageView()
    fileprivate let nameLabel: UILabel = UILabel()
    fileprivate let typeLabel: UILabel = UILabel()
    fileprivate let cancelButton: UIButton = UIButton()
    fileprivate let messageLabel: UILabel = UILabel()
    
    var cancelHandler : (() -> Void)?
    
    var actionType: String = ""
    
//MARK: LifeCycle
    class func compactPostView(_ type: String) -> CompactPostView {
        let compactPostView = CompactPostView()
        compactPostView.actionType = type
        compactPostView.initialSetup()
        
        return compactPostView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: self.contentView.bounds)
        self.contentView.layer.masksToBounds = false
        self.contentView.layer.shadowColor = ColorBucket.parentShadowColor.cgColor
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.contentView.layer.shadowOpacity = 0.15
        self.contentView.layer.shadowPath = shadowPath.cgPath
        self.contentView.isOpaque = true
    }
}


//MARK: Interface
extension CompactPostView: Interface {
    func configureWithCompletePost(_ post: Post) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(post.author) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        self.nameLabel.text = post.author.displayName
        self.messageLabel.text = post.message
    }
    
    func configureWithPost(_ post: Post, action: String) {
        self.typeLabel.text = (action == ActionType.Edit) ? "Edit message" : "Reply message"
        self.messageLabel.text = post.message
    }
    
    func requeredSize() -> CGSize {
        var width = UIScreen.screenWidth()
        if (self.actionType == ActionType.CompleteReply) {
            width -= (Constants.UI.FeedCellMessageLabelPaddings + Constants.UI.PostStatusViewSize)
        }
        return CGSize(width: width, height: BaseHeight)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupBackground()
    func setupContentView()
    func setupSeparatorView()
    func setupAvatarImageView()
    func setupNameLabel()
    func setupTypeLabel()
    func setupMessageLabel()
}

fileprivate protocol Action {
    func cancelAction()
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
        } else {
            setupTypeLabel()
            setupCancelButton()
        }
        setupMessageLabel()
    }
    
    func setupBackground() {
        self.backgroundColor = (self.actionType != ActionType.CompleteReply) ? ColorBucket.editBackgroundColor : UIColor.white
    }
    
    func setupContentView() {
        self.contentView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentBackgroundColor : UIColor.white
        
        self.contentView.layer.cornerRadius = 3.0
        let width = self.requeredSize().width - Constants.UI.StandardPaddingSize
        self.contentView.frame = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.LongPaddingSize, width: width, height: ContentHeight)
        
        self.addSubview(self.contentView)
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = (self.actionType == ActionType.CompleteReply) ? ColorBucket.parentSeparatorColor : ColorBucket.editSeparatorColor
        self.contentView.addSubview(self.separatorView)
        self.separatorView.frame = CGRect(x: Constants.UI.LongPaddingSize, y: Constants.UI.ShortPaddingSize, width: SeparatorSize.width, height: SeparatorSize.height)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.backgroundColor = self.contentView.backgroundColor
        self.avatarImageView.frame = CGRect(x: Constants.UI.DoublePaddingSize, y: Constants.UI.ShortPaddingSize,
                                                width: Constants.UI.StandardPaddingSize, height: Constants.UI.StandardPaddingSize)
        self.avatarImageView.layer.cornerRadius = Constants.UI.MiddlePaddingSize
        self.avatarImageView.layer.masksToBounds = true
        self.contentView.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        self.nameLabel.backgroundColor = self.contentView.backgroundColor
        self.nameLabel.font = FontBucket.parentAuthorNameFont
        self.nameLabel.textColor = ColorBucket.parentAuthorColor
        let originX = Constants.UI.DoublePaddingSize + Constants.UI.StandardPaddingSize + Constants.UI.ShortPaddingSize
        let width = self.requeredSize().width - (originX + Constants.UI.DoublePaddingSize)
        self.nameLabel.frame = CGRect(x: originX, y: Constants.UI.ShortPaddingSize, width: width, height: Constants.UI.StandardPaddingSize)
        self.contentView.addSubview(self.nameLabel)
    }
    
    func setupTypeLabel() {
        self.typeLabel.backgroundColor = self.contentView.backgroundColor
        self.typeLabel.font = FontBucket.editTypeFont
        self.typeLabel.textColor = ColorBucket.editSeparatorColor
        let width = self.requeredSize().width - (3 * Constants.UI.DoublePaddingSize + Constants.UI.ShortPaddingSize)
        self.typeLabel.frame = CGRect(x: Constants.UI.DoublePaddingSize, y: Constants.UI.LongPaddingSize, width: width, height: 14)
        self.contentView.addSubview(self.typeLabel)
    }
    
    func setupCancelButton() {
        self.cancelButton.backgroundColor = self.contentView.backgroundColor
        self.cancelButton.setImage(UIImage(named: "close button"), for: UIControlState())
        let x = self.typeLabel.frame.origin.x + self.typeLabel.frame.size.width + Constants.UI.ShortPaddingSize
        self.cancelButton.frame = CGRect(x: x, y: Constants.UI.ShortPaddingSize, width: Constants.UI.StandardPaddingSize, height: Constants.UI.StandardPaddingSize)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        self.contentView.addSubview(self.cancelButton)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = self.contentView.backgroundColor
        self.messageLabel.font = (self.actionType == ActionType.CompleteReply) ? FontBucket.parentMessageFont : FontBucket.messageFont
        self.messageLabel.textColor = ColorBucket.parentMessageColor
        let width = self.requeredSize().width - 2 * Constants.UI.DoublePaddingSize
        self.messageLabel.frame = CGRect(x: Constants.UI.DoublePaddingSize, y: Constants.UI.DoublePaddingSize + Constants.UI.MiddlePaddingSize, width: width, height: Constants.UI.StandardPaddingSize)
        self.contentView.addSubview(self.messageLabel)
    }
}


//MARK: Action
extension CompactPostView: Action {
    func cancelAction() {
        self.cancelHandler!()
    }
}
