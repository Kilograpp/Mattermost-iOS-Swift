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
  //  func configureBasicLabels()
    func configureAvatarImageView()
}

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
        guard self.post.author != nil else { return }
        
        
        
        
        
        
        
        //let channelWidth = CGFloat(self.post.channel.displayNameWidth)
        //let nameWidth = CGFloat(self.post.author.displayNameWidth)
        //let timeWidth = CGFloat(self.post.createdAtStringWidth)
        //let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        //let textHeight = CGFloat(self.post.attributedMessageHeight)
        
        //self.channelLabel.frame = CGRect(x: Constants.UI.MiddlePaddingSize,
          //                               y: Constants.UI.MiddlePaddingSize, width: channelWidth, height: 14)
        
    /*    self.nameLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize,
                                      y: self.channelLabel.frame.maxY + Constants.UI.MiddlePaddingSize,
                                      width: nameWidth, height: Constants.UI.DoublePaddingSize)
        
        self.timeLabel.frame = CGRect(x: self.nameLabel.frame.maxX + Constants.UI.ShortPaddingSize,
                                      y: self.nameLabel.frame.origin.y,
                                      width: timeWidth, height: Constants.UI.DoublePaddingSize)*/
        
     /*   self.messageLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize,
                                         y: self.nameLabel.frame.maxY + Constants.UI.ShortPaddingSize,
                                         width: textWidth, height: textHeight)*/
        
        /* self.arrowImageView.center = CGPoint(x: self.messageLabel.frame.maxX + Constants.UI.StandardPaddingSize,
                                             y: self.messageLabel.frame.maxY / 1.5)*/
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawChannelName()
        drawBasicInfo()
    }
}


//MARK: FeedSearchTableViewCellConfiguration
extension FeedSearchTableViewCell: FeedSearchTableViewCellConfiguration {
   /* final func configureBasicLabels() {
        guard self.post.author != nil else { return }
        
        self.channelLabel.text = self.post.channel.displayName!
        self.nameLabel.text = self.post.author.displayName
        self.timeLabel.text = self.post.createdAtString
    }*/
    
    final func configureAvatarImageView() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        guard self.post.author != nil else { return }
        
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { (image, error) in
            guard (self.postIdentifier == postIdentifier) else { return }
            self.avatarImageView.image = image
        }
    }
}


protocol FeedSearchTableViewCellSetup {
    func initialSetup()
    func setupAvatarImageView()
    func setupArrowImageView()
}

fileprivate protocol Drawing {
    func drawChannelName()
    func drawBasicInfo()
}

protocol FeedSearchTableViewCellAction {
    func disclosureTapAction()
}


//MARK: FeedSearchTableViewCellSetup
extension FeedSearchTableViewCell: FeedSearchTableViewCellSetup {
    func initialSetup() {
       // setupChannelLabel()
        setupAvatarImageView()
        setupArrowImageView()
    }

  /*  func setupChannelLabel() {
        self.channelLabel.backgroundColor = ColorBucket.whiteColor
        self.channelLabel.textColor = ColorBucket.channelColor
        self.channelLabel.font = FontBucket.channelFont
        self.addSubview(self.channelLabel)
    }*/
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.DoublePaddingSize + Constants.UI.MiddlePaddingSize, width: 40, height: 40)
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        self.avatarImageView.layer.cornerRadius = 20
        self.avatarImageView.layer.masksToBounds = true
        self.addSubview(self.avatarImageView)
    }
    
  /*  func setupNameLabel() {
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
    }*/
    
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


//MARK: Drawing
extension FeedSearchTableViewCell: Drawing {
    func drawChannelName() {
        let channelWidth = CGFloat(self.post.channel.displayNameWidth)
        let channelRect = CGRect(x: Constants.UI.MiddlePaddingSize, y: Constants.UI.MiddlePaddingSize, width: channelWidth, height: CGFloat(14))
        (self.post.channel.displayName! as NSString).draw(in: channelRect, withAttributes: [NSFontAttributeName : FontBucket.channelFont, NSForegroundColorAttributeName : ColorBucket.channelColor])
    }
    
    func drawBasicInfo() {
        guard self.post.author != nil else { return }
        
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let nameRect = CGRect(x: Constants.UI.MessagePaddingSize, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        
        
        
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        (self.post.author.displayName! as NSString).draw(in: CGRect(x: Constants.UI.MessagePaddingSize, y: 8, width: nameWidth, height: 20), withAttributes: [NSFontAttributeName : FontBucket.postAuthorNameFont, NSForegroundColorAttributeName : ColorBucket.blackColor])
        (self.post.createdAtString! as NSString).draw(in: CGRect(x: Constants.UI.MessagePaddingSize + nameWidth + 5, y: 11, width: dateWidth, height: 15), withAttributes: [NSFontAttributeName : FontBucket.postDateFont, NSForegroundColorAttributeName : ColorBucket.grayColor])
    }
}


//MARK: FeedSearchTableViewCellAction
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
     //   configureBasicLabels()
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
