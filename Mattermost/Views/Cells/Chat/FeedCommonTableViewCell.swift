//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage

protocol _FeedCommonTableViewCellConfiguration : class {
    func configureAvatarImage()
    func configureParentView()
}

class FeedCommonTableViewCell: FeedBaseTableViewCell {
    
//MARK: Properties
    fileprivate let avatarImageView: UIImageView = UIImageView()
  //  fileprivate let nameLabel: UILabel = UILabel()
//    fileprivate let dateLabel: UILabel = UILabel()
    fileprivate let parentView: CompactPostView = CompactPostView.compactPostView(ActionType.CompleteReply)

    var avatarTapHandler : (() -> Void)?
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupAvatarImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        guard !self.post.isInvalidated else { return }
        guard self.post.author != nil else { return }
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        
        var y: CGFloat = self.post.isFollowUp ? 0 : 36
        y += self.post.hasParentPost() ? (64 + Constants.UI.ShortPaddingSize) : 0
        
        self.messageLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize, y: y,
                                         width: textWidth, height: CGFloat(self.post.attributedMessageHeight))
        
        let size = self.parentView.requeredSize()
        self.parentView.frame = CGRect(x: Constants.UI.MessagePaddingSize,
                                       y: 36, width: size.width, height: size.height)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard self.post.author != nil else { return }
        guard !self.post.isFollowUp else { return }
        
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        (self.post.author.displayName! as NSString).draw(in: CGRect(x: Constants.UI.MessagePaddingSize, y: 8, width: nameWidth, height: 20), withAttributes: [NSFontAttributeName : FontBucket.postAuthorNameFont, NSForegroundColorAttributeName : ColorBucket.blackColor])
        (self.post.createdAtString! as NSString).draw(in: CGRect(x: Constants.UI.MessagePaddingSize + nameWidth + 5, y: 11, width: dateWidth, height: 15), withAttributes: [NSFontAttributeName : FontBucket.postDateFont, NSForegroundColorAttributeName : ColorBucket.grayColor])
    }
}


//MARK - Configuration
extension FeedCommonTableViewCell : _FeedCommonTableViewCellConfiguration {
    final func configureAvatarImage() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        
        guard !self.post.isFollowUp else { self.avatarImageView.image = nil; return }
        
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
            guard self?.postIdentifier == postIdentifier else { return }
            self?.avatarImageView.image = image
        }
    }
    
    final func configureParentView() {
        if (self.post.hasParentPost()) {
            self.parentView.configureWithCompletePost(self.post.parentPost()!)
            self.addSubview(self.parentView)
        } else {
            self.parentView.removeFromSuperview()
        }
    }
}


protocol _FeedCommonTableViewCellSetup : class {
    func setupAvatarImageView()
 //   func setupNameLabel()
 //   func setupDateLabel()
}

protocol _FeedCommonTableViewCellAction: class {
    func avatarTapAction()
}

protocol ParentComment: class {
    func setupParentCommentView()
}


//MARK: FeedCommonTableViewCellSetup
extension FeedCommonTableViewCell : _FeedCommonTableViewCellSetup  {
    final func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill

        self.addSubview(self.avatarImageView)
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /* final func setupNameLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.nameLabel.textColor = ColorBucket.blackColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    final func setupDateLabel() {
        self.dateLabel.backgroundColor = UIColor.white
        self.addSubview(self.dateLabel)
        self.dateLabel.font = FontBucket.postDateFont
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.dateLabel.textColor = ColorBucket.grayColor
    }*/
}


//MARK: FeedCommonTableViewCellAction
extension FeedCommonTableViewCell: _FeedCommonTableViewCellAction {
    func avatarTapAction() {
        if (self.avatarTapHandler != nil) { self.avatarTapHandler!() }
    }
}


//MARK: TableViewPostDataSource
extension FeedCommonTableViewCell : TableViewPostDataSource {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        
        guard self.post.author != nil else { return }
        
        configureAvatarImage()
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        var height: CGFloat = post.isFollowUp ? 0 : 44
        height += CGFloat(post.attributedMessageHeight)
        
        if (post.hasParentPost()) {
            height += 64 + Constants.UI.ShortPaddingSize
        }
        
        return height
    }
}
