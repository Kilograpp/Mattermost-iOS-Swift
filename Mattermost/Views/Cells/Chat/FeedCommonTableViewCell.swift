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
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        
        guard !self.post.isInvalidated else { return }
        guard self.post.author != nil else { return }
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        
        var y: CGFloat = self.post.isFollowUp ? 8 : 36
        y += self.post.hasParentPost() ? (64 + Constants.UI.ShortPaddingSize) : 0
        self.messageLabel.frame = CGRect(x: Constants.UI.MessagePaddingSize, y: y, width: textWidth, height: CGFloat(self.post.attributedMessageHeight))
        
        let size = self.parentView.requeredSize()
        
        if self.post.hasParentPost() {
            self.parentView.frame = CGRect(x: Constants.UI.MessagePaddingSize, y: 36, width: size.width, height: size.height)
        }
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.parentView.removeFromSuperview()
        self.backgroundColor = UIColor.white
        self.messageLabel.backgroundColor = UIColor.white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard self.post.author != nil else { return }
        guard !self.post.isFollowUp else { return }
        
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        let authorStringFrame = CGRect(x: Constants.UI.MessagePaddingSize, y: 8, width: nameWidth, height: 20)
        let authorStringAttributes = [NSFontAttributeName : FontBucket.postAuthorNameFont, NSForegroundColorAttributeName : ColorBucket.blackColor]
        (self.post.author.displayName! as NSString).draw(in: authorStringFrame, withAttributes: authorStringAttributes)
        
        let dateStringFrame = CGRect(x: Constants.UI.MessagePaddingSize + nameWidth + 5, y: 11, width: dateWidth, height: 15)
        let dateStringAttributes = [NSFontAttributeName : FontBucket.postDateFont, NSForegroundColorAttributeName : ColorBucket.grayColor]
        (self.post.createdAtString! as NSString).draw(in: dateStringFrame, withAttributes: dateStringAttributes)
    }
}


//MARK - Configuration
extension FeedCommonTableViewCell : _FeedCommonTableViewCellConfiguration {
    final func configureAvatarImage() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        
        guard !self.post.isFollowUp else { self.avatarImageView.isHidden = true; return }
        
        self.avatarImageView.isHidden = false
        self.avatarImageView.image = UIImage.avatarPlaceholder()
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
        //self.avatarImageView.layer.cornerRadius = 20.0
        //self.avatarImageView.clipsToBounds = true
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill

        self.addSubview(self.avatarImageView)
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
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
        
        let isf = post.isFollowUp ? 0 : 30
        setNeedsDisplay(CGRect(x: 53, y: 0, width: Int(UIScreen.screenWidth() - 80), height: isf))
//        setNeedsDisplay()
        if self.post.author != nil { configureAvatarImage() }
        if self.post.parentPost() != nil { configureParentView() }
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        var height: CGFloat = post.isFollowUp ? 16 : 44
        height += CGFloat(post.attributedMessageHeight)
        if (post.hasParentPost()) { height += 64 + Constants.UI.ShortPaddingSize }
        
        return height
    }
    
    override func highlightBackground() {
        let color = ColorBucket.selectedPostFromSearchBackgroundColor
        self.backgroundColor = color
        self.avatarImageView.image = UIImage.roundedImageOfSize(self.avatarImageView.image!,size: CGSize(width: 40, height: 40),
                                                                backgroundColor: .white,
                                                                hightlighted: false)
        
        self.messageLabel.backgroundColor = ColorBucket.modificatedTransparentBrightBlueColor
    }
}

//MARK: LongTapConfigure
extension FeedCommonTableViewCell {
    override func configureForSelectedState() {
        super.configureForSelectedState()
        avatarImageView.backgroundColor = UIColor.kg_lightLightGrayColor()
        self.avatarImageView.image = UIImage.roundedImageOfSize(self.avatarImageView.image!, size: CGSize(width: 40, height: 40),
                                                                backgroundColor: UIColor.kg_lightLightGrayColor(),
                                                                hightlighted: false)
    }
    
    override func configureForNoSelectedState() {
        super.configureForNoSelectedState()
        avatarImageView.backgroundColor = .white
        self.avatarImageView.image = UIImage.roundedImageOfSize(self.avatarImageView.image!, size: CGSize(width: 40, height: 40),
                                                                backgroundColor: .white,
                                                                hightlighted: false)
    }
}
