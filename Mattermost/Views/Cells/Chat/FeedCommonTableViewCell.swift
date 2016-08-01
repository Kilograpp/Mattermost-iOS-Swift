//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import ActiveLabel
import WebImage


class FeedCommonTableViewCell: UITableViewCell {
    //FIXME: CodeReview: В приват все лишнее
    let avatarImageView : UIImageView = UIImageView()
    let nameLabel : UILabel = UILabel()
    let dateLabel : UILabel = UILabel()
    let messageLabel : ActiveLabel = ActiveLabel()
    var messageDrawOperation : NSBlockOperation?
    
    //FIXME: CodeReview: Ячейка может без поста работать? Если нет, то в implicity unwrap. 
    //FIXME: CodeReview: В приват
    var post : Post?
    //FIXME: CodeReview: В final
    var onMentionTap: ((nickname : String) -> Void)?
    
    static var messageQueue : NSOperationQueue = {
        //FIXME: CodeReview: Убрать инит
        let queue = NSOperationQueue.init()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
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
    
    //MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()

        //FIXME: CodeReview: Лишние кастования.
        let nameWidth = CGFloat((self.post?.author.displayNameWidth)!) as CGFloat
        let dateWidth = CGFloat(self.post!.createdAtStringWidth) as CGFloat
        
        
        let textWidth = UIScreen.screenWidth() - 61 as CGFloat
        
        //FIXME: CodeReview: Убрать лишние скобочки, анвраппинг и тп
        self.messageLabel.frame = CGRectMake(53, 36, textWidth - 22, CGFloat((self.post?.attributedMessageHeight)!))
        self.nameLabel.frame = CGRectMake(53, 8, nameWidth, 20)
        self.dateLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, 8, dateWidth, 20)
    }
    
    override func prepareForReuse() {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        self.messageLabel.attributedText = nil
        self.messageDrawOperation?.cancel()
    }
}


protocol FeedCommonTableViewCellConfiguration : class {
    func configureAvatarImage()
    func configureMessageOperation()
    func configureBasicLabels()
}


protocol FeedCommonTableViewCellSetup : class {
    func setupAvatarImageView()
    func setupNameLabel()
    func setupDateLabel()
    func setupMessageLabel()
}


//MARK: - FeedTableViewCellProtocol
extension FeedCommonTableViewCell : FeedTableViewCellProtocol {
    //FIXME: CodeReview: Убрать войд
    func configureWithPost(post: Post) -> Void {
        self.post = post
        self.configureAvatarImage()
        self.configureMessageOperation()
        self.configureBasicLabels()
    }
    
    //FIXME: CodeReview: Заменить class на static
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44
    }
}

//MARK: - Setup
extension FeedCommonTableViewCell : FeedCommonTableViewCellSetup  {
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
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0;
        self.addSubview(self.messageLabel)
        self.configureMessageAttributedLabel()
        //TODO: assign closures
    }
}

//MARK - Configuration
extension FeedCommonTableViewCell : FeedCommonTableViewCellConfiguration {
    final func configureAvatarImage() {
        //FIXME: CodeReview: Убрать лишние анврапы
        SDWebImageManager.sharedManager().downloadImageWithURL(self.post?.author?.avatarURL(),
                                                               options: .HandleCookies,
                                                               progress: nil,
               completed: { [unowned self] (image, error, cacheType, isFinished, imageUrl) in
                if image != nil {
                    self.avatarImageView.image = UIImage.roundedImageOfSize(image, size: CGSizeMake(40, 40))
                }
                
        
        })
    }
    
    final func configureMessageOperation() {
        messageDrawOperation = NSBlockOperation(block: { [unowned self] in
            if self.messageDrawOperation?.cancelled == false {
                dispatch_sync(dispatch_get_main_queue(), {
                    //FIXME: CodeReview: Лишние анврапы
                    self.messageLabel.attributedText = self.post?.attributedMessage
                })
            }
        })
        
        FeedCommonTableViewCell.messageQueue.addOperation(self.messageDrawOperation!)
    }
    
    final func configureBasicLabels() {
        //FIXME: CodeReview: Лишние анврапы
        self.nameLabel.text = self.post?.author?.displayName
        self.dateLabel.text = self.post?.createdAtString
    }
  
}

