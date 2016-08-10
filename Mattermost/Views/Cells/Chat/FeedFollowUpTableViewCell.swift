//
//  FeedFollowUpTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


final class FeedFollowUpTableViewCell: FeedBaseTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        let textWidth = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings
        self.messageLabel.frame = CGRectMake(53, 8, textWidth, CGFloat(self.post.attributedMessageHeight))
    }
}

extension FeedFollowUpTableViewCell: TableViewPostDataSource {
    override class func heightWithPost(post: Post) -> CGFloat {
        return CGFloat(post.attributedMessageHeight) + 16
    }
}