//
//  ChatBaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


protocol TableViewPostDataSource: class {
    func configureWithPost(_ post: Post)
    static func heightWithPost(_ post: Post) -> CGFloat
}

class FeedBaseTableViewCell: UITableViewCell, Reusable {
    
//MARK: Properties
    final var onMentionTap: ((_ nickname : String) -> Void)?
    var errorHandler: ((_ post: Post) -> Void)?
    final var post : Post! {
        didSet {
            self.postIdentifier = self.post.identifier
            self.parentPostIdentifier = self.post.hasParentPost() ? self.post.parentId : nil
        }
    }
    final var postIdentifier: String?
    final var parentPostIdentifier: String?
    final var messageLabel = MessageLabel()
    final var postStatusView: PostStatusView!
    
    
//MARK: LifeCycle
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
        postStatusView.frame = CGRect(x: UIScreen.screenWidth() - Constants.UI.PostStatusViewSize, y: (frame.height - Constants.UI.PostStatusViewSize)/2, width: Constants.UI.PostStatusViewSize, height: Constants.UI.PostStatusViewSize)
        
        self.align()
        self.alignSubviews()
    }
    
    fileprivate func configureMessage() {
        
//        print(self.post.attributedMessage!)
        
        self.messageLabel.textStorage = self.post.attributedMessage!
        guard self.post.messageType == .system else { return }
        self.messageLabel.alpha = 0.5
    }
    
    
    fileprivate func setup() {
        setupBasics()
        setupMessageLabel()
        setupPostStatusView()
    }
    
    fileprivate func setupBasics() {
        self.selectionStyle = .none
    }

    fileprivate func setupMessageLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        messageLabel.isUserInteractionEnabled = true
        messageLabel.onUrlTap = { (url:URL) in
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
    
    fileprivate func setupPostStatusView() {
        postStatusView = PostStatusView()
        self.addSubview(postStatusView)
    }
    
}

protocol ChatMessageTapActions {
    func emailTapAction(_ email:String)
    func phoneTapAction(_ phone:String)
    func openURL(_ url:URL)
}

extension FeedBaseTableViewCell: ChatMessageTapActions {
    func emailTapAction(_ email:String) {
        let url = URL(string: "mailto:" + email)
        UIApplication.shared.openURL(url!)
    }
    func phoneTapAction(_ phone:String) {
        let url = URL(string: "tel:" + phone)
        UIApplication.shared.openURL(url!)
    }
    func openURL(_ url:URL) {
        UIApplication.shared.openURL(url)
    }
}

extension FeedBaseTableViewCell {
    func configureWithPost(_ post: Post) {
        self.post = post
        self.configureMessage()
        postStatusView.configureWithStatus(post)
        postStatusView.errorHandler = self.errorHandler
    }
    
    class func heightWithPost(_ post: Post) -> CGFloat {
        preconditionFailure("This method must be overridden")
    }
}

extension TableViewPostDataSource {
    func configureWithPost(_ post: Post) {}
}
