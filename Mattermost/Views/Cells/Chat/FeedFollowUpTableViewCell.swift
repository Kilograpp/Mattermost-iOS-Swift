//
//  FeedFollowUpTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


class FeedFollowUpTableViewCell: UITableViewCell, FeedTableViewCellProtocol {
    var messageLabel : MessageLabel = MessageLabel()
    
    var post : Post!
    var onMentionTap: ((nickname : String) -> Void)?

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupMessageLabel()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func setupMessageLabel()  {
        self.messageLabel.backgroundColor = UIColor.whiteColor()
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        self.addSubview(self.messageLabel)
        self.configureMessageAttributedLabel()
        //fonts & coloring
        //assign closures
    }
    
    func configureMessage() {
        self.messageLabel.attributedText = self.post.attributedMessage
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
        self.messageLabel.frame = CGRectMake(53, 8, textWidth, CGFloat(self.post.attributedMessageHeight))
    }
    
    override func prepareForReuse() {
        self.messageLabel.attributedText = nil
    }

}

extension FeedFollowUpTableViewCell {
    func configureWithPost(post: Post) -> Void {        
        self.post = post
        self.configureMessage()
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 16
    }
}