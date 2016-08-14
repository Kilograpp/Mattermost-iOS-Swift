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
    final var post : Post! {
        didSet { self.postIdentifier = self.post.identifier }
    }
    final var postIdentifier: String?
    final var messageLabel = MessageLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    override func prepareForReuse() {
        self.messageLabel.alpha = 1
        self.postIdentifier = nil
    }
    
    override func layoutSubviews() {
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
    }
    
    private func setupBasics() {
        self.selectionStyle = .None
    }

    private func setupMessageLabel() {
        //FIXME: CodeReview: Заменить на конкретный цвет
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        self.addSubview(self.messageLabel)
    }
    
}

extension FeedBaseTableViewCell {
    func configureWithPost(post: Post) {
        self.post = post
        self.configureMessage()
    }
    
    class func heightWithPost(post: Post) -> CGFloat {
        preconditionFailure("This method must be overridden")
    }
}

extension TableViewPostDataSource {
    func configureWithPost(post: Post) {}
}