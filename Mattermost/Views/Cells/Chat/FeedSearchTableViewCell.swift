//
//  FeedSearchTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 29.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage

class FeedSearchTableViewCell: FeedBaseTableViewCell {
    
//MARK: Properties
    fileprivate let avatarImageView: UIImageView = UIImageView()
    fileprivate let arrowImageView: UIImageView = UIImageView()
    
    var disclosureTapHandler : (() -> Void)?
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        self.messageLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize, y: 50,
                                         width: textWidth, height: CGFloat(self.post.attributedMessageHeight))
        
        self.arrowImageView.center = CGPoint(x: self.messageLabel.frame.maxX + Constants.UI.StandardPaddingSize,
                                             y: self.messageLabel.frame.maxY / 2)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let channelWidth = CGFloat(self.post.channel.displayNameWidth)
        let channelRect = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.MiddlePaddingSize, width: channelWidth, height: CGFloat(14))
        (self.post.channel.displayName! as NSString).draw(in: channelRect, withAttributes: [NSFontAttributeName : FontBucket.channelFont, NSForegroundColorAttributeName : ColorBucket.channelColor])
        
        guard self.post.author != nil else { return }
        
        var username = self.post.author.displayName!
        var displayNameWidth = self.post.author.displayNameWidth
        if self.post.overrideUsername! != "" {
            username = self.post.overrideUsername!
            displayNameWidth = StringUtils.widthOfString(username as NSString!, font: FontBucket.postAuthorNameFont)
        }

        let nameWidth = CGFloat(displayNameWidth)
        let nameRect = CGRect(x: Constants.UI.MessagePaddingSize, y: channelRect.maxY + Constants.UI.MiddlePaddingSize, width: nameWidth, height: 20)
        (username as NSString).draw(in: nameRect, withAttributes: [NSFontAttributeName : FontBucket.postAuthorNameFont, NSForegroundColorAttributeName : ColorBucket.blackColor])
        
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        let dateRect = CGRect(x: Constants.UI.MessagePaddingSize + nameWidth + 5, y: nameRect.origin.y + 2, width: dateWidth, height: 20)
        (self.post.createdAtString! as NSString).draw(in: dateRect, withAttributes: [NSFontAttributeName : FontBucket.postDateFont, NSForegroundColorAttributeName : ColorBucket.grayColor])
    }
}


protocol FeedSearchTableViewCellSetup {
    func initialSetup()
    func setupAvatarImageView()
    func setupArrowImageView()
}

protocol FeedSearchTableViewCellConfiguration {
    func configureAvatarImageView()
}

protocol FeedSearchTableViewCellAction {
    func disclosureTapAction()
}


//MARK: Setup
extension FeedSearchTableViewCell: FeedSearchTableViewCellSetup {
    func initialSetup() {
        setupAvatarImageView()
        setupArrowImageView()
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.DoublePaddingSize + Constants.UI.MiddlePaddingSize, width: 40, height: 40)
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        self.avatarImageView.layer.cornerRadius = 20
        self.avatarImageView.layer.masksToBounds = true
        self.addSubview(self.avatarImageView)
    }
    
    func setupArrowImageView() {
        self.arrowImageView.image = UIImage(named: "comments_send_icon")
        self.arrowImageView.frame = CGRect(x: 0, y: 0, width: 16, height: 14)
        self.arrowImageView.backgroundColor = ColorBucket.whiteColor
        self.arrowImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.disclosureTapAction))
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(self.arrowImageView)
    }
}


//MARK: Configuration
extension FeedSearchTableViewCell: FeedSearchTableViewCellConfiguration {
    final func configureAvatarImageView() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        var author = self.post.author
        if self.post.fromWebhook == true {
            author = DataManager.sharedInstance.systemUser
        }
        
        guard author != nil else { return }
        
        ImageDownloader.downloadFeedAvatarForUser(author!) { (image, error) in
            guard (self.postIdentifier == postIdentifier) else { return }
            self.avatarImageView.image = image
        }
    }
}


//MARK: Action
extension FeedSearchTableViewCell: FeedSearchTableViewCellAction {
    func disclosureTapAction() {
        self.disclosureTapHandler!()
    }
}


//MARK: TableViewPostDataSource
extension FeedSearchTableViewCell: TableViewPostDataSource {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        
        configureAvatarImageView()
    }
    
    final func configureSelectionWithText(text: String) {
        let notAllowedCharacters = CharacterSet.init(charactersIn: "!@#$%^&*()_+|,;.\"'")
        let result = text.components(separatedBy: notAllowedCharacters).joined(separator: "")
//        let range = (self.messageLabel.textStorage!.string.lowercased() as NSString).range(of: result.lowercased())
//        
//        self.messageLabel.textStorage?.addAttributes([NSBackgroundColorAttributeName : ColorBucket.searchTextBackgroundColor], range: range)
//        self.messageLabel.textStorage?.addAttributes([NSForegroundColorAttributeName : ColorBucket.searchTextColor], range: range)
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 64
    }
}
