//
//  ChatBaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


import RealmSwift

protocol TableViewPostDataSource: class {
    func configureWithPost(_ post: Post)
    static func heightWithPost(_ post: Post) -> CGFloat
    func highlightBackground()
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
    final var messageLabel = CTLabel()
    final var postStatusView: PostStatusView!
    final var notificationToken: NotificationToken?
    
    
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
        self.messageLabel.alpha = 1
        self.postIdentifier = nil
        self.parentPostIdentifier = nil
        notificationToken?.stop()
        self.backgroundColor = .white
        messageLabel.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        postStatusView.frame = CGRect(x: UIScreen.screenWidth() - Constants.UI.PostStatusViewSize, y: (frame.height - Constants.UI.PostStatusViewSize)/2, width: Constants.UI.PostStatusViewSize, height: Constants.UI.PostStatusViewSize)
        
        self.align()
        self.alignSubviews()
    }
    
    fileprivate func configureMessage() {
        switch self.post.messageType {
        case .system:
            self.messageLabel.layoutData = post.renderedText
            break
        case .default:
            self.messageLabel.layoutData = post.renderedText
        case .slackAttachment:
            post.renderedText = AttributedTextLayoutData(text: post.attachments.first!.attributedText!, maxWidth: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize)
        }
        self.messageLabel.layoutData = post.renderedText
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
        self.messageLabel.backgroundColor = ColorBucket.whiteColor
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
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url.URLWithScheme(.HTTP)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func mentionTapAction(_ mentionString: String) {
        //add impl
    }
}

extension FeedBaseTableViewCell {
    func configureWithPost(_ post: Post) {
        self.post = post
        self.configureMessage()
        postStatusView.configureWithStatus(post)
        postStatusView.errorHandler = self.errorHandler
        
        notificationToken = post.addNotificationBlock { change in
            switch change {
            case .change(let properties):
                if properties.first(where: { $0.name == "status" }) != nil {
                    self.postStatusView.configureWithStatus(self.post)
                }
                if properties.first(where: { $0.name == "message" }) != nil {
                    RealmUtils.configuratePost(post: self.post)
                    self.configureMessage()
                }
                if properties.first(where: { $0.name == "isFollowUp" }) != nil && properties.count == 1 {
                    self.configureWithPost(self.post)
                    (self.superview?.superview as! UITableView).reloadData()

                }
                if let attributeMessageProperty = properties.first(where: { $0.name == "_attributedMessageData" }) {
                    let newAttributedString = (attributeMessageProperty.newValue as! RealmAttributedString).attributedString!
                    post.computeRenderedTextWith(attrStr: newAttributedString)
                    self.configureMessage()
                }
            case .deleted:
                print("deleted")
            case .error(let error):
                print("deleted")
            }
        }
    }
    
    class func heightWithPost(_ post: Post) -> CGFloat {
        preconditionFailure("This method must be overridden")
    }
    
    func highlightBackground() {
        preconditionFailure("This method must be overridden")
    }
}

//MARK: LongTapConfigure
extension FeedBaseTableViewCell {
    func configureForSelectedState(action: String) {
        let selectingColor: UIColor!
        switch action {
        case Constants.PostActionType.SendReply:
                selectingColor = UIColor.kg_lightLightGrayColor()
        case Constants.PostActionType.SendUpdate:
                selectingColor = UIColor.kg_editColor()
        default:
            selectingColor = UIColor.kg_lightLightGrayColor()
        }
        self.backgroundColor = selectingColor
        messageLabel.backgroundColor = selectingColor
    }
    
    func configureForNoSelectedState() {
        self.backgroundColor = .white
        messageLabel.backgroundColor = .white
    }
}

extension TableViewPostDataSource {
    func configureWithPost(_ post: Post) {}
}
