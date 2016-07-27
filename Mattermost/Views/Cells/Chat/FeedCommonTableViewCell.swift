//
//  ChatCommonTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import ActiveLabel
import WebImage


class FeedCommonTableViewCell: UITableViewCell, FeedTableViewCellProtocol {
    var avatarImageView : UIImageView?
    var nameLabel : UILabel?
    var dateLabel : UILabel?
    var messageLabel : ActiveLabel?
    var messageDrawOperation : NSBlockOperation?
    
    var post : Post?
    var onMentionTap: ((nickname : String) -> Void)?
    
    static var messageQueue : NSOperationQueue = {
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
    
    
    //MARK: Setup
    
    func setupAvatarImageView() -> Void {
        self.avatarImageView = UIImageView.init(frame: CGRectMake(8, 8, 40, 40))
        self.avatarImageView?.backgroundColor = UIColor.whiteColor()
        self.avatarImageView?.contentMode = .ScaleAspectFill
        self.addSubview(self.avatarImageView!)
        self.avatarImageView?.image = UIImage.sharedAvatarPlaceholder
        //add gesture recognizer
    }
    
    func setupNameLabel() -> Void {
        self.nameLabel = UILabel.init()
        self.nameLabel!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.nameLabel!)
        //fonts & coloring
    }
    
    func setupDateLabel() -> Void {
        self.dateLabel = UILabel.init()
        self.dateLabel!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.dateLabel!)
        //fonts & coloring
    }
    
    func setupMessageLabel() -> Void {
        self.messageLabel = ActiveLabel.init()
        self.messageLabel!.backgroundColor = UIColor.whiteColor()
        self.messageLabel?.numberOfLines = 0;
        self.addSubview(self.messageLabel!)
        //fonts & coloring
        //assign closures
    }
    
    
    //MARK: Configuration
    
    func configureAvatarImage() -> Void {
        weak var weakSelf = self
        SDWebImageManager.sharedManager().downloadImageWithURL(self.post?.author?.avatarURL(), options: .HandleCookies, progress: nil, completed: {(image, error, cacheType, isFinished, imageUrl) in
            weakSelf?.avatarImageView?.image = UIImage.roundedImageOfSize(image, size: CGSizeMake(40, 40))
        })
    }
    
    func configureMessageOperation() -> Void {
        messageDrawOperation = NSBlockOperation.init(block: {
            //FIXME: replace with weakSelf
            if ((self.messageDrawOperation?.cancelled)! == false) {
                dispatch_sync(dispatch_get_main_queue(), { 
                    self.messageLabel?.attributedText = self.post?.attributedMessage
                })
            }
        })
        
        FeedCommonTableViewCell.messageQueue.addOperation(self.messageDrawOperation!)
    }
    
    func configureBasicLabels() -> Void {
        self.nameLabel?.text = self.post?.author?.displayName
        self.dateLabel?.text = self.post?.createdAtString
    }
    
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //FIXME: replace with real one
        let nameWidth = CGFloat((self.post?.author?.nicknameWidth)!) as CGFloat
        let dateWidth = CGFloat(self.post!.createdAtStringWidth) as CGFloat
        let textWidth = UIScreen.screenWidth() - 61 as CGFloat
        
        self.messageLabel?.frame = CGRectMake(53, 36, textWidth - 22, CGFloat((self.post?.attributedMessageHeight)!))
        self.nameLabel?.frame = CGRectMake(53, 8, nameWidth, 20)
        self.dateLabel?.frame = CGRectMake(CGRectGetMaxX(self.nameLabel!.frame) + 5, 8, dateWidth, 20)
    }
    
    override func prepareForReuse() {
        self.avatarImageView?.image = nil
        self.messageLabel?.attributedText = nil
        self.messageDrawOperation?.cancel()
    }
}


extension FeedCommonTableViewCell {
    func configureWithPost(post: Post) -> Void {
        assert(post.isKindOfClass(Post), "Object must me instance of 'Post' class")
        
        self.post = post
        self.configureAvatarImage()
        self.configureMessageOperation()
        self.configureBasicLabels()
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44
    }
}

