//
//  ChannelsMoreTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 17.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage

protocol ChannelsMoreTableViewCellConfiguration {
    func configureWith(resultTuple: ResultTuple)
    func cellHeigth() -> CGFloat
    func configureWith(user: User)
    func configureWith(channel: Channel)
    func configureAvatarForPrivate(channel: Channel)
    func configureAvatarForPublic(channel: Channel)
    
}

class ChannelsMoreTableViewCell: UITableViewCell, Reusable {
    let avatarImageView = UIImageView()
    let channelLetterLabel = UILabel()
    let nameLabel = UILabel()
    let checkBoxButton = UIButton()
    let separatorView = UIView()
    
    var checkBoxHandler : (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: Configuration

extension ChannelsMoreTableViewCell: ChannelsMoreTableViewCellConfiguration {
    func configureWith(resultTuple: ResultTuple) {
        if (resultTuple.object.isKind(of: Channel.self)) {
            configureWith(channel: (resultTuple.object as! Channel))
        }
        else {
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
        self.channelLetterLabel.superview?.isHidden = true
        self.nameLabel.text = user.displayName
    }
    
    func configureWith(channel: Channel) {
        if (channel.privateType == Constants.ChannelType.PublicTypeChannel) {
            configureAvatarForPublic(channel: channel)
        }
        if (channel.privateType == Constants.ChannelType.PrivateTypeChannel) {
            configureAvatarForPrivate(channel: channel)
        }
        if (channel.privateType == Constants.ChannelType.DirectTypeChannel) {
            configureAvatarForDirect(channel: channel)
        }
        
        self.nameLabel.text = channel.displayName
    }
    
    func configureAvatarForPublic(channel: Channel) {
        self.avatarImageView.image = nil
        self.channelLetterLabel.superview?.isHidden = false
        self.channelLetterLabel.text = channel.displayName![0]
        
        let backgroundLayer = self.channelLetterLabel.superview?.layer.sublayers?[0] as! CAGradientLayer
        backgroundLayer.updateLayer(backgroundLayer)
    }

    func configureAvatarForPrivate(channel: Channel) {
        self.avatarImageView.image = nil
        self.channelLetterLabel.superview?.isHidden = false
        self.channelLetterLabel.text = channel.displayName![0]
        
        let backgroundLayer = self.channelLetterLabel.superview?.layer.sublayers?[0] as! CAGradientLayer
        backgroundLayer.updateLayer(backgroundLayer)
    }
    
    func configureAvatarForDirect(channel: Channel) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        let user = channel.interlocuterFromPrivateChannel()
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        self.channelLetterLabel.superview?.isHidden = true
    }
}


private protocol ChannelsMoreTableViewCellSetup {
    func initialSetup()
    func setupAvatarImageView()
    func setupChannelLetterLabel()
    func setupNameLabel()
    func setupCheckBoxButton()
}

private protocol ChannelsMoreTableViewCellAction {
    func checkBoxAction()
}

//MARK: Setup

extension ChannelsMoreTableViewCell: ChannelsMoreTableViewCellSetup {
    func initialSetup() {
        self.selectionStyle = .none
        setupAvatarImageView()
        setupChannelLetterLabel()
        setupNameLabel()
        setupCheckBoxButton()
        setupSeparatorView()
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.layer.cornerRadius = Constants.UI.DoublePaddingSize
        self.avatarImageView.layer.masksToBounds = true
        self.addSubview(self.avatarImageView)
    }
    
    func setupChannelLetterLabel() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        self.channelLetterLabel.frame = frame
        self.channelLetterLabel.backgroundColor = UIColor.clear
        self.channelLetterLabel.font = FontBucket.letterChannelFont
        self.channelLetterLabel.textColor = ColorBucket.whiteColor
        self.channelLetterLabel.textAlignment = .center
        
        let backgroundView = UIView(frame: frame)
        let layer = CAGradientLayer.blueGradientForAvatarImageView()
        layer.frame = CGRect(x:0, y:0, width:40, height: 40)
        backgroundView.layer.insertSublayer(layer, at: 0)
        backgroundView.addSubview(self.channelLetterLabel)
        
        self.avatarImageView.addSubview(backgroundView)
    }
    
    func setupNameLabel() {
        self.nameLabel.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.nameLabel.backgroundColor = ColorBucket.whiteColor
        self.nameLabel.textColor = ColorBucket.authorColor
        self.nameLabel.font = FontBucket.postAuthorNameFont
        self.addSubview(self.nameLabel)
    }
    
    func setupCheckBoxButton() {
        self.checkBoxButton.frame = CGRect(x: 0, y: 0, width: Constants.UI.DoublePaddingSize, height: Constants.UI.DoublePaddingSize)
        self.checkBoxButton.backgroundColor = ColorBucket.whiteColor
        self.checkBoxButton.layer.cornerRadius = Constants.UI.DoublePaddingSize / 2
        self.checkBoxButton.layer.borderColor = ColorBucket.checkButtonBorderColor.cgColor
        self.checkBoxButton.layer.borderWidth = 1
        self.checkBoxButton.layer.masksToBounds = true
        self.checkBoxButton.setImage(UIImage(named: "check_blue"), for: .selected)
        self.checkBoxButton.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        self.addSubview(self.checkBoxButton)
    }
    
    func setupSeparatorView() {
        self.separatorView.backgroundColor = ColorBucket.separatorViewBackgroundColor
        self.addSubview(self.separatorView)
    }
}


//MARK: LifeCycle

extension ChannelsMoreTableViewCell {
    override func layoutSubviews() {
        self.avatarImageView.frame = CGRect(x: Constants.UI.StandardPaddingSize, y: Constants.UI.LongPaddingSize, width: 40, height: 40)
        
        let width = UIScreen.screenWidth() - self.avatarImageView.frame.maxX - 4 * Constants.UI.StandardPaddingSize - Constants.UI.DoublePaddingSize
        self.nameLabel.frame = CGRect(x: self.avatarImageView.frame.maxX + Constants.UI.StandardPaddingSize,
                                      y: Constants.UI.DoublePaddingSize,
                                      width: width,
                                      height: Constants.UI.DoublePaddingSize)
        
        self.checkBoxButton.frame = CGRect(x: self.nameLabel.frame.maxX + Constants.UI.DoublePaddingSize,
                                           y: Constants.UI.DoublePaddingSize,
                                           width: Constants.UI.DoublePaddingSize,
                                           height: Constants.UI.DoublePaddingSize)
        
        self.separatorView.frame = CGRect(x: 70, y: 59, width: UIScreen.screenWidth() - 70, height: 1)
 
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.avatarImageView.image = nil
        self.nameLabel.text = nil
    }
}


//MARK: Action

extension ChannelsMoreTableViewCell: ChannelsMoreTableViewCellAction {
    func checkBoxAction() {
        self.checkBoxButton.isSelected = !self.checkBoxButton.isSelected
        if (self.checkBoxHandler != nil) {
            self.checkBoxHandler!()
        }
    }
}
