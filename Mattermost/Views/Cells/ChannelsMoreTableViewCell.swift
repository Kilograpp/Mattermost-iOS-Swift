//
//  ChannelsMoreTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 17.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage

private protocol Configuration {
    func configureWith(resultTuple: ResultTuple)
    func cellHeigth() -> CGFloat
    
    func configureWith(user: User)
    func configureWith(channel: Channel)
    func configureAvatarForPrivate(channel: Channel)
    func configureAvatarForPublic(channel: Channel)
}

class ChannelsMoreTableViewCell: UITableViewCell, Reusable {
    
//MARK: Properties
    fileprivate let avatarImageView = UIImageView()
    fileprivate let channelLetterLabel = UILabel()
    fileprivate let nameLabel = UILabel()
    let checkBoxButton = UIButton()
    fileprivate let separatorLayer = CALayer()
    
    fileprivate var channelId: String = ""
    fileprivate var channel: Channel?
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        avatarImageView.frame = CGRect(x: Constants.UI.StandardPaddingSize, y: Constants.UI.LongPaddingSize, width: 40, height: 40)
        channelLetterLabel.frame = avatarImageView.frame
        
        let width = UIScreen.screenWidth() - self.avatarImageView.frame.maxX - 4 * Constants.UI.StandardPaddingSize - Constants.UI.DoublePaddingSize
        nameLabel.frame = CGRect(x: self.avatarImageView.frame.maxX + Constants.UI.StandardPaddingSize,
                                      y: Constants.UI.DoublePaddingSize,
                                      width: width,
                                      height: Constants.UI.DoublePaddingSize)
        
        checkBoxButton.frame = CGRect(x: self.nameLabel.frame.maxX + Constants.UI.DoublePaddingSize,
                                           y: Constants.UI.DoublePaddingSize,
                                           width: Constants.UI.DoublePaddingSize,
                                           height: Constants.UI.DoublePaddingSize)
        
        let separatorHeight = CGFloat(0.5)
        separatorLayer.frame = CGRect(x: 70, y: 60 - separatorHeight, width: UIScreen.screenWidth() - 70, height: separatorHeight)
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.avatarImageView.image = nil
        self.nameLabel.text = nil
    }
}


//MARK: Configuration
extension ChannelsMoreTableViewCell: Configuration {
    func configureWith(resultTuple: ResultTuple) {
        if (resultTuple.object.isKind(of: Channel.self)) {
            configureWith(channel: (resultTuple.object as! Channel))
        } else {
            configureWith(user: (resultTuple.object as! User))
        }
        self.checkBoxButton.isSelected = resultTuple.checked
    }
    
    func cellHeigth() -> CGFloat {
        return 60
    }
    
    func configureWith(user: User) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        self.nameLabel.text = user.displayName
    }
    
    func configureWith(channel: Channel) {
        self.channel = channel
        channelId = channel.identifier!
        if (channel.privateType == Constants.ChannelType.DirectTypeChannel) {
            configureAvatarForDirect(channel: channel)
        } else {
            configureAvatarForPublic(channel: channel)
        }
        
        self.nameLabel.text = channel.displayName
    }
    
    func configureAvatarForPublic(channel: Channel) {
        GradientImageBuilder.gradientImageWithType(type: channel.gradientType) { (image) in
            guard self.channelId == self.channel?.identifier else {return}
            
            self.avatarImageView.image = image
        }
        self.channelLetterLabel.text = channel.displayName![0]
    }

    func configureAvatarForPrivate(channel: Channel) {
        self.avatarImageView.image = nil
        self.channelLetterLabel.superview?.isHidden = false
        self.channelLetterLabel.text = channel.displayName![0]
    }
    
    func configureAvatarForDirect(channel: Channel) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        let user = channel.interlocuterFromPrivateChannel()
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        self.channelLetterLabel.isHidden = true
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupAvatarImageView()
    func setupChannelLetterLabel()
    func setupNameLabel()
    func setupCheckBoxButton()
}


//MARK: Setup
extension ChannelsMoreTableViewCell: Setup {
    func initialSetup() {
        selectionStyle = .none
        setupAvatarImageView()
        setupChannelLetterLabel()
        setupNameLabel()
        setupCheckBoxButton()
        setupSeparatorView()
    }
    
    func setupAvatarImageView() {
        avatarImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = Constants.UI.DoublePaddingSize
        avatarImageView.layer.masksToBounds = true
        addSubview(self.avatarImageView)
    }
    
    func setupChannelLetterLabel() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        channelLetterLabel.frame = frame
        channelLetterLabel.backgroundColor = UIColor.clear
        channelLetterLabel.font = FontBucket.letterChannelFont
        channelLetterLabel.textColor = ColorBucket.whiteColor
        channelLetterLabel.textAlignment = .center
        channelLetterLabel.textColor = UIColor.white
        
        addSubview(channelLetterLabel)
    }
    
    func setupNameLabel() {
        self.nameLabel.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        self.nameLabel.textColor = ColorBucket.authorColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    func setupCheckBoxButton() {
        checkBoxButton.frame = CGRect(x: 0, y: 0, width: Constants.UI.DoublePaddingSize, height: Constants.UI.DoublePaddingSize)
        checkBoxButton.backgroundColor = ColorBucket.whiteColor
        checkBoxButton.layer.cornerRadius = Constants.UI.DoublePaddingSize / 2
        checkBoxButton.layer.borderColor = ColorBucket.checkButtonBorderColor.cgColor
        checkBoxButton.layer.borderWidth = 1
        checkBoxButton.layer.masksToBounds = true
        checkBoxButton.setImage(UIImage(named: "check_blue"), for: .selected)
        checkBoxButton.isUserInteractionEnabled = false
        addSubview(checkBoxButton)
    }
    
    func setupSeparatorView() {
        separatorLayer.backgroundColor = ColorBucket.separatorViewBackgroundColor.cgColor
        self.layer.addSublayer(separatorLayer)
    }
}
