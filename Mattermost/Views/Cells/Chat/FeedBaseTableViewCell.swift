//
//  ChatBaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import ActiveLabel

protocol FeedTableViewCellProtocol : class, MattermostTableViewCellProtocol {
    var onMentionTap: ((nickname : String) -> Void)? { get set }
    var post : Post? { get set }
    var messageLabel : ActiveLabel? { get set }
    
    static var messageQueue : NSOperationQueue {get set}
    func configureWithPost(post: Post) -> Void
    func configureMessageAttributedLabel() -> Void
    static func heightWithPost(post: Post) -> CGFloat
}
//
//если нужна реализация
extension FeedTableViewCellProtocol {
    func configureMessageAttributedLabel() -> Void {
        self.messageLabel?.URLColor = ColorBucket.blueColor
        self.messageLabel?.URLSelectedColor = ColorBucket.blueColor
        self.messageLabel?.mentionColor = ColorBucket.blueColor
        self.messageLabel?.mentionSelectedColor = ColorBucket.blueColor
        self.messageLabel?.hashtagColor = ColorBucket.blueColor
    }
}
