//
//  MessageNotificationView.swift
//  Mattermost
//
//  Created by Tatiana on 09/09/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol MessageNotificationViewDelegate {
    func didSelectNotification(post : Post) -> Void
    func didCloseNotification() -> Void
}

class MessageNotificationView : UIView {
    
    private var avatarImageView : UIImageView = UIImageView.init()
    private var messageLabel : UILabel = UILabel.init()
    private var titleLabel : UILabel = UILabel.init()
    
    final let offset: CGFloat = 8
    final let avatarSize: CGFloat = 30
    final let mesageOffset: CGFloat = 45
    final let backgroundAlpha: CGFloat = 0.97
    var timer : NSTimer?
    var post : Post?
    
    init() {
        super.init(frame: CGRectZero)
        setup()
        setupAvatarImageView()
        setupMessageLabel()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configurateWithPost(post : Post) {
        self.timer?.invalidate()
        //self.timer = nil
        self.post = post
        self.messageLabel.text = post.message
        self.titleLabel.text = post.channel.displayName
        ImageDownloader.downloadFeedAvatarForUser((self.post?.author)!) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        
    }
    
    var delegate : MessageNotificationViewDelegate?
    
}

private protocol Setup {
    func setup()
    func setupAvatarImageView()
    func setupTitleLabel()
    func setupMessageLabel()
}

extension MessageNotificationView : Setup {
    func setup(){
        self.frame = CGRectMake(0, 0, UIScreen .mainScreen().bounds.width, 90)
        self.backgroundColor = ColorBucket.blackColor
        self.backgroundColor = self.backgroundColor?.colorWithAlphaComponent(backgroundAlpha)
        self.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseMessageAction))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(closeAction))
        swipeGestureRecognizer.direction = .Up
        self.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRectMake(offset, offset * 2, avatarSize, avatarSize)
        self.avatarImageView.backgroundColor = self.backgroundColor
        self.avatarImageView.layer.cornerRadius = 15
        self.avatarImageView.clipsToBounds = true
        self.addSubview(self.avatarImageView)
    }
    
    func setupMessageLabel() {
        self.messageLabel.frame = CGRectMake(mesageOffset, 30 + offset, UIScreen .mainScreen().bounds.width - offset - mesageOffset, avatarSize + offset * 2)
        self.messageLabel.font = FontBucket.subtitleServerUrlFont
        self.messageLabel.textColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0
        self.addSubview(self.messageLabel)
    }
    
    func setupTitleLabel() {
        self.titleLabel.frame = CGRectMake(mesageOffset, offset * 2, UIScreen .mainScreen().bounds.width - offset - mesageOffset, mesageOffset - avatarSize)
        self.titleLabel.font = FontBucket.footerTitleFont
        self.titleLabel.textColor = ColorBucket.whiteColor
        self.addSubview(self.titleLabel)
    }
}

private protocol Action {
    func chooseMessageAction()
    func closeAction()
}

extension MessageNotificationView : Action {
    func chooseMessageAction() {
        self.timer = nil
        self.delegate?.didSelectNotification(self.post!)
    }
    
    func closeAction() {
        self.timer = nil
        self.timer?.invalidate()
        self.delegate?.didCloseNotification()
    }
}