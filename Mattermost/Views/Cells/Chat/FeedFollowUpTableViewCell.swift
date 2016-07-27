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
}

extension FeedFollowUpTableViewCell {
    func configureWithPost(post: Post) -> Void {
        assert(post.isKindOfClass(Post), "Object must me instance of 'Post' class")
        
        self.post = post
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 44
    }
}
