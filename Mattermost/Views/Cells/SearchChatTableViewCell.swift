//
//  SearchChatTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 13.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

//TODO: Main part of realization will be added soon

import UIKit
import NVActivityIndicatorView

struct Geometry {
    static let AvatarDimension: CGFloat = 40.0
    static let StandartPadding: CGFloat = 8.0
    static let SmallPadding: CGFloat    = 5.0
    static let ErrorViewSize: CGFloat   = 34.0
}
// FIXME: CodeReview: Приватные протоколы должны находиться после определения класса (
private protocol LifeCycle {
    func awakeFromNib()
    func setSelected(_ selected: Bool, animated: Bool)
    func layoutSubviews()
    func prepareForReuse()
}

private protocol Setup {
    func initialSetup()
    func setupBackground()
    func setupChannelLabel()
    func setupAvatarImageView()
    func setupNameLabel()
    func setupDateLabel()
    func setupMessageLabel()
    func setupDetailIconImageView()
}

private protocol Private {

}

private protocol Configuration {
    func configureLabel(_ label: UILabel, font: UIFont, color: UIColor)
    func configureCellState()
    func configureBasicLabels()
    func configureAvatarImage()
}

private protocol Action {
    func showProfileAction()
}

class SearchChatTableViewCell: UITableViewCell {

//MARK: Properties
    // FIXME: CodeReview: Если у переменной указывается конструктор, то нет необходимости явно указывать тип после двоеточия, он определится сам.
    fileprivate let channelLabel: UILabel = UILabel()
    fileprivate let avatarImageView: UIImageView = UIImageView()
    fileprivate let nameLabel: UILabel = UILabel()
    fileprivate let timeLabel: UILabel = UILabel()
    fileprivate let messageLabel: MessageLabel = MessageLabel()
    fileprivate let detailIconImageView: UIImageView = UIImageView()
    
    fileprivate let timeString: String = ""
    // FIXME: CodeReview: Зачем держать сразу и post, и его identifier? Даже посты без identifier (т.е неотправленные) присутствуют в бд и отображаются.
    final var post : Post! {
        didSet { self.postIdentifier = self.post.identifier }
    }
    final var postIdentifier: String?
    
    
    //MARK: Public
   
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureWithPost(_ post: Post) {
        self.post = post
        configureBasicLabels()
        configureAvatarImage()
        configureMessageLabel()
    }
    
    func heighWithPost(_ post: Post) -> CGFloat {
        return 0.0
    }
    
    func errorAction() {
        
    }
}


//MARK: LifeCycle

extension SearchChatTableViewCell: LifeCycle {
    // FIXME: CodeReview: Если переопределенный метод не отличается от от родительского - нет смысла его переопределять.
    // FIXME: CodeReview: +переопределенные методы в extension не работают (лучше указывать их в классе) 
    //                      см. http://stackoverflow.com/questions/38213286/overriding-methods-in-swift-extensions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        
    }
}


//MARK: Setup

extension SearchChatTableViewCell: Setup {
    func initialSetup() {
        setupBackground()
        setupChannelLabel()
        setupAvatarImageView()
        setupNameLabel()
        setupDateLabel()
        setupMessageLabel()
        setupDetailIconImageView()
    }
    
    func setupBackground() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
    }
    
    func setupChannelLabel() {
        configureLabel(self.channelLabel, font: UIFont.kg_semibold13Font(), color: UIColor.kg_lightBlackColor())
        self.addSubview(self.channelLabel)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        self.avatarImageView.backgroundColor = UIColor.white
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        configureLabel(self.nameLabel, font: UIFont.kg_semibold15Font(), color: UIColor.kg_lightBlackColor())
        self.nameLabel.isUserInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.nameLabel)
    }
    
    func setupDateLabel() {
        configureLabel(self.timeLabel, font: UIFont.kg_regular13Font(), color: UIColor.kg_lightGrayTextColor())
        self.addSubview(self.timeLabel)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = UIColor.white
        // FIXME: CodeReview: 0 по умолчанию
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        self.addSubview(self.messageLabel)
    }
    
    func setupDetailIconImageView() {
        self.detailIconImageView.image = UIImage(named: "comments_send_icon")
        self.detailIconImageView.backgroundColor = UIColor.white
        self.detailIconImageView.contentMode = .scaleAspectFill
        self.addSubview(self.detailIconImageView)
    }
}


//MARK: Configuration

extension SearchChatTableViewCell: Configuration {
    func configureLabel(_ label: UILabel, font: UIFont, color: UIColor) {
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.numberOfLines = 1
        label.backgroundColor = UIColor.white
        label.font = font
        label.textColor = color
    }
    
    func configureCellState() {
        
    }
    
    func configureBasicLabels() {
        self.channelLabel.text = self.post.channel.name
        self.nameLabel.text = self.post.author.nickname
        self.timeLabel.text = self.post.createdAtString
        configureMessageLabel()
    }
    
    func configureAvatarImage() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        // FIXME: CodeReview: зачем проверять наличие у поста identifier?
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
            guard self?.postIdentifier == postIdentifier else { return }
            self?.avatarImageView.image = image
        }
    }
    
    func configureMessageLabel() {
        self.messageLabel.textStorage = self.post.attributedMessage!
        guard self.post.messageType == .system else { return }
        self.messageLabel.alpha = 0.5
    }
}


//MARK: Action

extension SearchChatTableViewCell: Action {
    func showProfileAction() {
    }
}
