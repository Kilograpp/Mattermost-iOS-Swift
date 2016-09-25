//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage

class FeedCommonTableViewCell: FeedBaseTableViewCell {
    private let avatarImageView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    private let dateLabel: UILabel = UILabel()
    private let parentView: CompactPostView = CompactPostView.compactPostView(ActionType.CompleteReply)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupAvatarImageView()
        self.setupNameLabel()
        self.setupDateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


protocol _FeedCommonTableViewCellConfiguration : class {
    func configureAvatarImage()
    func configureBasicLabels()
    func configureParentView()
}

protocol _FeedCommonTableViewCellSetup : class {
    func setupAvatarImageView()
    func setupNameLabel()
    func setupDateLabel()
}

protocol _FeedCommonTableViewCellLifeCycle: class {
    func prepareForReuse()
    func layoutSubviews()
}

protocol ParentComment: class {
    func setupParentCommentView()
}

extension FeedCommonTableViewCell : TableViewPostDataSource {
    override func configureWithPost(post: Post) {
        super.configureWithPost(post)
        self.configureAvatarImage()
        self.configureBasicLabels()
    }
    
    override class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44
    }
}


//MARK - Configuration

extension FeedCommonTableViewCell : _FeedCommonTableViewCellConfiguration {
    final func configureAvatarImage() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
            guard self?.postIdentifier == postIdentifier else { return }
            self?.avatarImageView.image = image

        }
    }
    
    final func configureBasicLabels() {
        self.nameLabel.text = self.post.author.displayName
        self.dateLabel.text = self.post.createdAtString
    }
    
    final func configureParentView() {
        if (self.post.hasParentPost()) {
            self.parentView.configureWithPost(self.post.parentPost()!)
        }
    }
}

//MARK: - Setup
extension FeedCommonTableViewCell : _FeedCommonTableViewCellSetup  {
    final func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        //FIXME: CodeReview: Конкретный цвет
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .ScaleAspectFill
        self.addSubview(self.avatarImageView)
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        //TODO: add gesture recognizer
    }
    
    final func setupNameLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.nameLabel.textColor = ColorBucket.blackColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    final func setupDateLabel() {
        self.dateLabel.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.dateLabel)
        self.dateLabel.font = FontBucket.postDateFont
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.dateLabel.textColor = ColorBucket.grayColor
    }
}

extension FeedCommonTableViewCell: _FeedCommonTableViewCellLifeCycle {
    override func layoutSubviews() {
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        
        self.messageLabel.frame = CGRectMake(53, 36, textWidth, CGFloat(self.post.attributedMessageHeight))
        self.nameLabel.frame = CGRectMake(53, 8, nameWidth, 20)
        self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, 8, dateWidth, 20)
        
        let size = self.parentView.requeredSize()
        self.parentView.frame = CGRectMake(60, 36, size.width, size.height)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}