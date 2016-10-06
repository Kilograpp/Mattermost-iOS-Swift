//
//  FeedSearchTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 29.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage

protocol FeedSearchTableViewCellConfiguration {
    func configureBasicLabels()
    func configureAvatarImageView()
}

protocol FeedSearchTableViewCellSetup {
    func initialSetup()
    func setupChannelLabel()
    func setupAvatarImageView()
    func setupNameLabel()
    func setupTimeLabel()
    func setupArrowImageView()
}

protocol FeedSearchTableViewCellAction {
    func disclosureTapAction()
}

class FeedSearchTableViewCell: FeedBaseTableViewCell {
    
//MARK: Properties
    
    fileprivate let channelLabel: UILabel = UILabel()
    fileprivate let avatarImageView: UIImageView = UIImageView()
    fileprivate let nameLabel: UILabel = UILabel()
    fileprivate let timeLabel: UILabel = UILabel()
    fileprivate let arrowImageView: UIImageView = UIImageView()
    
    var disclosureTapHandler : (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: TableViewPostDataSource

extension FeedSearchTableViewCell: TableViewPostDataSource {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        configureAvatarImageView()
        configureBasicLabels()
    }
    
    final func configureSelectionWithText(text: String) {
        let range = (self.post.message! as NSString).range(of: text)
        self.messageLabel.textStorage?.addAttributes([NSBackgroundColorAttributeName : ColorBucket.searchTextBackgroundColor], range: range)
        self.messageLabel.textStorage?.addAttributes([NSForegroundColorAttributeName : ColorBucket.searchTextColor], range: range)
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 64
    }
}


//MARK: Configuration

extension FeedSearchTableViewCell: FeedSearchTableViewCellConfiguration {
    final func configureBasicLabels() {
        self.channelLabel.text = "#" + self.post.channel.displayName!
        self.nameLabel.text = self.post.author.displayName
        self.timeLabel.text = self.post.createdAtString
    }
    
    final func configureAvatarImageView() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { (image, error) in
            guard (self.postIdentifier == postIdentifier) else { return }
            self.avatarImageView.image = image
        }
    }
}


//MARK: Setup

extension FeedSearchTableViewCell: FeedSearchTableViewCellSetup {
    func initialSetup() {
        setupChannelLabel()
        setupAvatarImageView()
        setupNameLabel()
        setupTimeLabel()
        setupArrowImageView()
    }

    func setupChannelLabel() {
        self.channelLabel.backgroundColor = ColorBucket.whiteColor
        self.channelLabel.textColor = ColorBucket.channelColor
        self.channelLabel.font = FontBucket.channelFont
        self.addSubview(self.channelLabel)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.DoublePaddingSize + Constants.UI.MiddlePaddingSize, width: 40, height: 40)
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        self.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        self.nameLabel.textColor = ColorBucket.authorColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    func setupTimeLabel() {
        self.timeLabel.backgroundColor = ColorBucket.whiteColor
        self.timeLabel.font = FontBucket.postDateFont
        self.timeLabel.textColor = ColorBucket.grayColor
        self.addSubview(self.timeLabel)
    }
    
    func setupArrowImageView() {
        self.arrowImageView.image = UIImage(named: "comments_send_icon")
        self.arrowImageView.frame = CGRect(x: 0, y: 0, width: 16, height: 14)
        self.arrowImageView.backgroundColor = ColorBucket.whiteColor
        self.arrowImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.disclosureTapAction))
        self.arrowImageView.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(self.arrowImageView)
    }
}


//MARK: LifeCycle

extension FeedSearchTableViewCell {
    override func layoutSubviews() {
        let channelWidth = CGFloat(self.post.channel.displayNameWidth)
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let timeWidth = CGFloat(self.post.createdAtStringWidth)
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        let textHeight = CGFloat(self.post.attributedMessageHeight)
        
        self.channelLabel.frame = CGRect(x: Constants.UI.MiddlePaddingSize,
                                         y: Constants.UI.MiddlePaddingSize, width: channelWidth, height: 14)
        
        self.nameLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize,
                                      y: self.channelLabel.frame.maxY + Constants.UI.MiddlePaddingSize,
                                      width: nameWidth, height: Constants.UI.DoublePaddingSize)
        
        self.timeLabel.frame = CGRect(x: self.nameLabel.frame.maxX + Constants.UI.ShortPaddingSize,
                                      y: self.nameLabel.frame.origin.y,
                                      width: timeWidth, height: Constants.UI.DoublePaddingSize)
        
        self.messageLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize,
                                         y: self.nameLabel.frame.maxY + Constants.UI.ShortPaddingSize,
                                         width: textWidth, height: textHeight)
        
        self.arrowImageView.center = CGPoint(x: self.messageLabel.frame.maxX + Constants.UI.StandardPaddingSize,
                                             y: self.messageLabel.frame.maxY / 1.5)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


//MARK: Action

extension FeedSearchTableViewCell: FeedSearchTableViewCellAction {
    func disclosureTapAction() {
        self.disclosureTapHandler!()
    }
}
