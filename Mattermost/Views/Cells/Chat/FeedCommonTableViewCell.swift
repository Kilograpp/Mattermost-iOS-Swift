//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage

class FeedCommonTableViewCell: FeedBaseTableViewCell {
    fileprivate let avatarImageView: UIImageView = UIImageView()
    fileprivate let nameLabel: UILabel = UILabel()
    fileprivate let dateLabel: UILabel = UILabel()
    fileprivate let parentView: CompactPostView = CompactPostView.compactPostView(ActionType.CompleteReply)

    var avatarTapHandler : (() -> Void)?
    
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

protocol _FeedCommonTableViewCellAction: class {
    func avatarTapAction()
}

protocol _FeedCommonTableViewCellLifeCycle: class {
    func prepareForReuse()
    func layoutSubviews()
}

protocol ParentComment: class {
    func setupParentCommentView()
}


extension FeedCommonTableViewCell : TableViewPostDataSource {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        self.configureAvatarImage()
        self.configureBasicLabels()
        configureParentView()
        
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        var height = CGFloat(post.attributedMessageHeight) + 44
        if (post.hasParentPost()) {
            height += 64 + Constants.UI.ShortPaddingSize
        }
        
        return height
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
            self.parentView.configureWithCompletePost(self.post.parentPost()!)
            self.addSubview(self.parentView)
        }
        else {
            self.parentView.removeFromSuperview()
        }
    }
}

//MARK: - Setup
extension FeedCommonTableViewCell : _FeedCommonTableViewCellSetup  {
    final func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        //FIXME: CodeReview: Конкретный цвет
        self.avatarImageView.backgroundColor = ColorBucket.whiteColor
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.layer.cornerRadius = 20
        self.avatarImageView.layer.masksToBounds = true
        self.addSubview(self.avatarImageView)
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapAction))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)
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
        self.dateLabel.backgroundColor = UIColor.white
        self.addSubview(self.dateLabel)
        self.dateLabel.font = FontBucket.postDateFont
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.dateLabel.textColor = ColorBucket.grayColor
    }
}

extension FeedCommonTableViewCell: _FeedCommonTableViewCellAction {
    func avatarTapAction() {
        if (self.avatarTapHandler != nil) {
            self.avatarTapHandler!()
        }
    }
}

extension FeedCommonTableViewCell: _FeedCommonTableViewCellLifeCycle {
    override func layoutSubviews() {
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        
        let originY = self.post.hasParentPost() ? (36 + 64 + Constants.UI.ShortPaddingSize) : 36
        self.messageLabel.frame = CGRect(x: 53, y: originY, width: textWidth, height: CGFloat(self.post.attributedMessageHeight))
        self.nameLabel.frame = CGRect(x: 53, y: 8, width: nameWidth, height: 20)
        self.dateLabel.frame = CGRect(x: self.nameLabel.frame.maxX + 5, y: 8, width: dateWidth, height: 20)
        
        let size = self.parentView.requeredSize()
        self.parentView.frame = CGRect(x: 53, y: 36, width: size.width, height: size.height)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
