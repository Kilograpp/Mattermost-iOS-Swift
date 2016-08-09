//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage
import Sugar


class FeedCommonTableViewCell: UITableViewCell {
    //FIXME: CodeReview: В приват все лишнее
    let avatarImageView : UIImageView = UIImageView()
    let nameLabel : UILabel = UILabel()
    let dateLabel : UILabel = UILabel()
    let messageLabel : MessageLabel = MessageLabel()
    
    private var postIdentifier: String?
    
    //FIXME: CodeReview: Ячейка может без поста работать? Если нет, то в implicity unwrap. 
    //FIXME: CodeReview: В приват
    var post : Post!
    //FIXME: CodeReview: В final
    var onMentionTap: ((nickname : String) -> Void)?
    
    //MARK: Init
    
     override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupAvatarImageView()
        self.setupNameLabel()
        self.setupMessageLabel()
        self.setupDateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


protocol _FeedCommonTableViewCellConfiguration : class {
    func configureAvatarImage()
    func configureMessage()
    func configureBasicLabels()
}

protocol _FeedCommonTableViewCellSetup : class {
    func setupAvatarImageView()
    func setupNameLabel()
    func setupDateLabel()
    func setupMessageLabel()
}

protocol _FeedCommonTableViewCellLifeCycle: class {
    func prepareForReuse()
    func layoutSubviews()
}


//MARK: - FeedTableViewCellProtocol

extension FeedCommonTableViewCell : FeedTableViewCellProtocol {
    //FIXME: CodeReview: Убрать войд
    func configureWithPost(post: Post) -> Void {
        self.post = post
        self.configureAvatarImage()
        self.configureMessage()
        self.configureBasicLabels()
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44
    }
}


//MARK - Configuration

extension FeedCommonTableViewCell : _FeedCommonTableViewCellConfiguration {
    final func configureAvatarImage() {

        let smallAvatarCacheKey = self.post.author.smallAvatarCacheKey()
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        
        if let image = SDImageCache.sharedImageCache().imageFromMemoryCacheForKey(smallAvatarCacheKey) {
            self.avatarImageView.image = image
        } else {
            self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                [weak self] (image, error, cacheType, isFinished, imageUrl) in
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    
                    // Handle unpredictable errors
                    guard image != nil else {
                        print(error)
                        return
                    }
                    
                    let processedImage = UIImage.roundedImageOfSize(image, size: CGSizeMake(40, 40))
                    SDImageCache.sharedImageCache().storeImage(processedImage, forKey: smallAvatarCacheKey)
                    
                    // Ensure the post is still the same
                    guard self?.postIdentifier == postIdentifier else {
                        return
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        self?.avatarImageView.image = processedImage
                    })
                    
                }
            }
            
            SDWebImageManager.sharedManager().downloadImageWithURL(self.post.author.avatarURL(),
                                                                   options: .HandleCookies ,
                                                                   progress: nil,
                                                                   completed: imageDownloadCompletionHandler)
        }

    }
    
    final func configureMessage() {

        PerformanceManager.sharedInstance.messageRenderOperationQueue.addOperationWithBlock { 
            dispatch_sync(dispatch_get_main_queue()) {
                self.messageLabel.attributedText = self.post.attributedMessage
            }
        }
    }
    
    final func configureBasicLabels() {
        self.nameLabel.text = self.post.author.displayName
        self.dateLabel.text = self.post.createdAtString
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
    
    final func setupMessageLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0;
        self.addSubview(self.messageLabel)
        self.configureMessageAttributedLabel()
        //TODO: assign closures
    }
}

extension FeedCommonTableViewCell: _FeedCommonTableViewCellLifeCycle {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let nameWidth = CGFloat(self.post.author.displayNameWidth)
        let dateWidth = CGFloat(self.post.createdAtStringWidth)
        
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
        
        self.messageLabel.frame = CGRectMake(53, 36, textWidth, CGFloat(self.post.attributedMessageHeight))
        self.nameLabel.frame = CGRectMake(53, 8, nameWidth, 20)
        self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, 8, dateWidth, 20)
    }
    
    override func prepareForReuse() {
        self.messageLabel.attributedText = nil
    }
    
}

