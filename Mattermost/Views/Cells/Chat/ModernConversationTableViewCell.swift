//
//  ModernConversationTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 21.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

private protocol Public : class {
    func configureWithPost(_ post: Post)
    static func heightWithPost(_ post: Post) -> CGFloat
}

final class ModernConversationTableViewCell : UITableViewCell, Reusable {
    final var post : Post!
    
    fileprivate final var messageLabel = CTLabel()
    fileprivate final var avatarImage = UIImage.sharedAvatarPlaceholder
    
    fileprivate var postIdentifier : String?
    fileprivate static let avatarImageFrame = CGRect(x: 8, y: 8, width: 40, height: 40)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubview(messageLabel)
        messageLabel.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var y: CGFloat = self.post.isFollowUp ? 8 : 36
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        y += self.post.hasParentPost() ? (64 + Constants.UI.ShortPaddingSize) : 0
        let frame = CGRect(x: Constants.UI.MessagePaddingSize, y: y, width: textWidth, height: CGFloat(self.post.attributedMessageHeight))
        messageLabel.frame = frame

    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if rect != bounds && !self.post.isFollowUp {
            let imgFrame = ModernConversationTableViewCell.avatarImageFrame
            avatarImage.draw(in: imgFrame, blendMode: .normal, alpha: 1.0)
            return
        }
        
        guard self.post.author != nil else { return }
        guard !self.post.isFollowUp else { return }
        
        if !self.post.isFollowUp {
            let nameWidth = CGFloat(self.post.author.displayNameWidth)
            let dateWidth = CGFloat(self.post.createdAtStringWidth)
            let authorStringFrame = CGRect(x: Constants.UI.MessagePaddingSize, y: 8, width: nameWidth, height: 20)
            let authorStringAttributes = [NSFontAttributeName : FontBucket.postAuthorNameFont, NSForegroundColorAttributeName : ColorBucket.blackColor]
            (self.post.author.displayName! as NSString).draw(in: authorStringFrame, withAttributes: authorStringAttributes)
            
            let dateStringFrame = CGRect(x: Constants.UI.MessagePaddingSize + nameWidth + 5, y: 11, width: dateWidth, height: 15)
            let dateStringAttributes = [NSFontAttributeName : FontBucket.postDateFont, NSForegroundColorAttributeName : ColorBucket.grayColor]
            (self.post.createdAtString! as NSString).draw(in: dateStringFrame, withAttributes: dateStringAttributes)
            
            let imgFrame = ModernConversationTableViewCell.avatarImageFrame
            avatarImage.draw(in: imgFrame, blendMode: .normal, alpha: 1.0)
        }
        
        if post.hasParentPost() {
            
        }
    }

}

extension ModernConversationTableViewCell : Public {
    func configureWithPost(_ post: Post) {
        self.post = post
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        
        messageLabel.layoutData = post.renderedText
        if !post.isFollowUp {
            ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
                guard self?.postIdentifier == postIdentifier else { return }
                
                self?.avatarImage = image!
                self?.setNeedsDisplay(ModernConversationTableViewCell.avatarImageFrame)
            }
        }
        
        setNeedsDisplay()
    }
    
    static func heightWithPost(_ post: Post) -> CGFloat {
        var height: CGFloat = post.isFollowUp ? 16 : 44
        height += CGFloat(post.attributedMessageHeight)
        if (post.hasParentPost()) { height += 64 + Constants.UI.ShortPaddingSize }
        
        return height
    }
}
