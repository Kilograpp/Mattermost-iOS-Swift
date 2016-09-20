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
    static let LoadingViewSize: CGFloat = 22.0
    static let ErrorViewSize: CGFloat   = 34.0
}

private protocol LifeCycle {
    func awakeFromNib()
    func setSelected(selected: Bool, animated: Bool)
    func layoutSubviews()
    func prepareForReuse()
}

private protocol Setup {

}

private protocol Private {

}

private protocol Configuration {
    func configureLabel(label: UILabel, font: UIFont, color: UIColor)
    func configureCellState()
    func configureBasicLabels()
    func configureMessageOperation()
    func configureAvatarImage()
}

private protocol Action {
    func showProfileAction()
}

class SearchChatTableViewCell: FeedBaseTableViewCell {

//MARK: Properties
    private let channelLabel: UILabel = UILabel()
    private let avatarImageView: UIImageView = UIImageView()
    private let nameLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let detailIconImageView: UIImageView = UIImageView()
    private let loadingView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRectZero)
    
    private let messageOperation: NSBlockOperation = NSBlockOperation()
    private let timeString: String = ""
    
    
    //MARK: Public
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureWithPost(post: Post) {
        
    }
    
    func heighWithPost(post: Post) -> CGFloat {
        return 0.0
    }
    
    func errorAction() {
        
    }
}


//MARK: LifeCycle

extension SearchChatTableViewCell: LifeCycle {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
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
        
    }
    
    func setupBackground() {
        self.selectionStyle = .None
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setupChannelLabel() {
        configureLabel(self.channelLabel, font: UIFont.kg_semibold13Font(), color: UIColor.kg_lightBlackColor())
        self.addSubview(self.channelLabel)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRectMake(8, 8, 40, 40)
        self.avatarImageView.backgroundColor = UIColor.whiteColor()
        self.avatarImageView.contentMode = .ScaleAspectFill
        self.avatarImageView.userInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        configureLabel(self.nameLabel, font: UIFont.kg_semibold15Font(), color: UIColor.kg_lightBlackColor())
        self.nameLabel.userInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.nameLabel)
    }
    
    func setupDateLabel() {
        configureLabel(self.timeLabel, font: UIFont.kg_regular13Font(), color: UIColor.kg_lightGrayTextColor())
        self.addSubview(self.timeLabel)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = UIColor.whiteColor()
        self.messageLabel.numberOfLines = 0
        self.messageLabel.layer.drawsAsynchronously = true
        self.addSubview(self.messageLabel)
    }
    
    func setupDetailIconImageView() {
        self.detailIconImageView.image = UIImage(named: "comments_send_icon")
        self.detailIconImageView.backgroundColor = UIColor.whiteColor()
        self.detailIconImageView.contentMode = .ScaleAspectFill
        self.addSubview(self.detailIconImageView)
    }
    
    func setupLoadingView() {
        self.loadingView.type = .BallPulse
        self.loadingView.tintColor = UIColor.kg_blueColor()
        self.loadingView.padding = Geometry.LoadingViewSize - Geometry.SmallPadding
        self.loadingView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(self.loadingView)
    }

}


//MARK: Configuration

extension SearchChatTableViewCell: Configuration {
    func configureLabel(label: UILabel, font: UIFont, color: UIColor) {
        label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        label.numberOfLines = 1
        label.backgroundColor = UIColor.whiteColor()
        label.font = font
        label.textColor = color
    }
    
    func configureCellState() {
       
    }
    
    func configureBasicLabels() {
        self.channelLabel.text = self.post.channel.name
        self.nameLabel.text = self.post.author.nickname
        self.timeLabel.text = self.post.createdAtString
    }
    
    func configureMessageOperation() {
        
    }
    
    func configureAvatarImage() {        
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
            guard self?.postIdentifier == postIdentifier else { return }
            self?.avatarImageView.image = image
            
        }
    }
}


//MARK: Action

extension SearchChatTableViewCell: Action {
    func showProfileAction() {
    }
}