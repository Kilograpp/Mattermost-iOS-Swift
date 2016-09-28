//
//  ChatBaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//



protocol TableViewPostDataSource: class {
    func configureWithPost(post: Post)
    static func heightWithPost(post: Post) -> CGFloat
}

class FeedBaseTableViewCell: UITableViewCell, Reusable {
    final var onMentionTap: ((nickname : String) -> Void)?
    var errorHandler: ((post: Post) -> Void)?
    final var post : Post! {
        didSet { self.postIdentifier = self.post.identifier
            self.parentPostIdentifier = self.post.hasParentPost() ? self.post.parentId : nil}
    }
    final var postIdentifier: String?
    final var parentPostIdentifier: String?
    final var messageLabel = MessageLabel()
    final var postStatusView: PostStatusView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    override func prepareForReuse() {
        self.messageLabel.textStorage = nil
        self.messageLabel.alpha = 1
        self.postIdentifier = nil
    }
    
    override func layoutSubviews() {
        postStatusView.frame = CGRectMake(UIScreen.screenWidth() - Constants.UI.PostStatusViewSize, (CGRectGetHeight(frame) - Constants.UI.PostStatusViewSize)/2, Constants.UI.PostStatusViewSize, Constants.UI.PostStatusViewSize)
        
        self.align()
        self.alignSubviews()
    }
    
    private func configureMessage() {
        self.messageLabel.textStorage = self.post.attributedMessage!
        guard self.post.messageType == .System else { return }
        self.messageLabel.alpha = 0.5
    }
    
    
    private func setup() {
        self.setupBasics()
        self.setupMessageLabel()
        setupPostStatusView()
    }
    
    private func setupBasics() {
        self.selectionStyle = .None
    }

    private func setupMessageLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        messageLabel.userInteractionEnabled = true
        messageLabel.onUrlTap = { (url:NSURL) in
            self.openURL(url)
        }
        messageLabel.onEmailTap = { (email:String) in
            self.emailTapAction(email)
        }
        messageLabel.onPhoneTap = { (phone:String) in
            self.phoneTapAction(phone)
        }
        self.addSubview(self.messageLabel)
    }
    
    private func setupPostStatusView() {
        postStatusView = PostStatusView()
        self.addSubview(postStatusView)
    }
    
}

protocol ChatMessageTapActions {
    func emailTapAction(email:String)
    func phoneTapAction(phone:String)
    func openURL(url:NSURL)
}

extension FeedBaseTableViewCell: ChatMessageTapActions {
    func emailTapAction(email:String) {
        let url = NSURL(string: "mailto:" + email)
        UIApplication.sharedApplication().openURL(url!)
    }
    func phoneTapAction(phone:String) {
        let url = NSURL(string: "tel:" + phone)
        UIApplication.sharedApplication().openURL(url!)
    }
    func openURL(url:NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}

extension FeedBaseTableViewCell {
    func configureWithPost(post: Post) {
        self.post = post
        self.configureMessage()
        postStatusView.configureWithStatus(post)
        postStatusView.errorHandler = self.errorHandler
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        preconditionFailure("This method must be overridden")
    }
}

extension TableViewPostDataSource {
    func configureWithPost(post: Post) {}
}
