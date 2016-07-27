//
//  FeedFollowUpTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import ActiveLabel

class FeedFollowUpTableViewCell: UITableViewCell, FeedTableViewCellProtocol {
    var messageLabel : ActiveLabel?
    var messageDrawOperation : NSBlockOperation?
    
    var post : Post?
    var onMentionTap: ((nickname : String) -> Void)?
    
    static var messageQueue : NSOperationQueue = {
        let queue = NSOperationQueue.init()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupMessageLabel()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func setupMessageLabel() -> Void {
        self.messageLabel = ActiveLabel.init()
        self.messageLabel!.backgroundColor = UIColor.whiteColor()
        self.messageLabel?.numberOfLines = 0;
        self.addSubview(self.messageLabel!)
        //fonts & coloring
        //assign closures
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textWidth = UIScreen.screenWidth() - 61 as CGFloat
        self.messageLabel?.frame = CGRectMake(53, 8, textWidth - 22, CGFloat((self.post?.attributedMessageHeight)!))
    }

}

extension FeedFollowUpTableViewCell {
    func configureWithPost(post: Post) -> Void {
        assert(post.isKindOfClass(Post), "Object must me instance of 'Post' class")
        
        self.post = post
        self.configureMessageOperation()
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 16
    }
}