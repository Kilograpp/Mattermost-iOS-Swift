//
//  MoreChannelsTableViewCell.swift
//  Mattermost
//
//  Created by Mariya on 31.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

//MARK: - PublicProtocol
private protocol PublicHeightCellMoreChannels : class {
    static func height()->(CGFloat)
}

private protocol Configure : class {
    func configureCellWithObject(_ channel: Channel)
}

final class MoreChannelsTableViewCell: UITableViewCell, Reusable {

//MARK: - Property
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var letterFirstNamesChannelLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var nameChannelLabel: UILabel!
    @IBOutlet weak var lastPostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarUsersLastPostImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!

//MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAvatarView()
        setupAvatarImageView()
        setupStatusView()
        setupNameChannelLabel()
        setupLastPostLabel()
        setupDateLabel()
        setupAvatarUsersLastPostImageView()
        setupSeparatorView()
        setupLetterFirstNamesChannelLabel()
    }

}

//MARK: - PrivateProtocol
private protocol Setup : class {
    func setupAvatarView()
    func setupAvatarImageView()
    func setupStatusView()
    func setupNameChannelLabel()
    func setupLastPostLabel()
    func setupDateLabel()
    func setupAvatarUsersLastPostImageView()
    func setupSeparatorView()
    func setupLetterFirstNamesChannelLabel()
}

//MARK: - PublicHeightCellMoreChannels
extension MoreChannelsTableViewCell: PublicHeightCellMoreChannels {
    
    class func height()->(CGFloat) {
        return 80
    }
}

//MARK: - Setup
extension MoreChannelsTableViewCell : Setup {
    
    fileprivate func setupAvatarView(){
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height/2
        self.avatarView.backgroundColor = ColorBucket.whiteColor
        
    }
    
    fileprivate func setupAvatarImageView(){
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height/2
        self.avatarImageView.clipsToBounds = true
    }
    
    fileprivate func setupStatusView() {
        self.statusView.layer.cornerRadius = self.statusView.bounds.height/2
        self.statusView.layer.borderWidth = 2
        self.statusView.layer.borderColor = ColorBucket.whiteColor.cgColor
        self.statusView.backgroundColor = ColorBucket.darkGrayColor
        self.avatarView.bringSubview(toFront: self.statusView)
    }
    
    fileprivate func setupNameChannelLabel(){
        self.nameChannelLabel.textColor = ColorBucket.blackColor
        self.nameChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.nameChannelLabel.font = FontBucket.titleChannelFont
        self.nameChannelLabel.numberOfLines = 1
    }
    
    fileprivate func setupLastPostLabel(){
        self.lastPostLabel.textColor = ColorBucket.blackColor
        self.lastPostLabel.backgroundColor = ColorBucket.whiteColor
        self.lastPostLabel.font = FontBucket.subtitleChannelFont
        self.lastPostLabel.numberOfLines = 2
    }
    
    fileprivate func setupDateLabel(){
        self.dateLabel.textColor = ColorBucket.grayColor
        self.dateLabel.backgroundColor = ColorBucket.whiteColor
        self.dateLabel.font = FontBucket.dateChannelFont
    }
    
    fileprivate func setupAvatarUsersLastPostImageView(){
        self.avatarUsersLastPostImageView.layer.cornerRadius = self.avatarUsersLastPostImageView.bounds.height/2
        self.avatarUsersLastPostImageView.clipsToBounds = true
    }
    
    fileprivate func setupSeparatorView(){
        self.separatorView.backgroundColor = ColorBucket.rightMenuSeparatorColor
    }
    
    fileprivate func setupLetterFirstNamesChannelLabel(){
        self.letterFirstNamesChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.tintColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.font = FontBucket.letterChannelFont
    }
}

extension MoreChannelsTableViewCell : Configure {

//MARK: - ConfigureCell
    func configureCellWithObject(_ channel: Channel) {
        if channel.privateType == Constants.ChannelType.PrivateTypeChannel {
            configureHiddenForSubviews(true)
            configureCellWithPrivateChannel(channel)
        }
        if channel.privateType == Constants.ChannelType.PublicTypeChannel  {
            configureHiddenForSubviews(false)
            configureCellWithPublicChannel(channel)
        }
    }
    
    fileprivate func configureHiddenForSubviews(_ hidden: Bool) {
        self.letterFirstNamesChannelLabel.isHidden = hidden
        self.avatarUsersLastPostImageView.isHidden = hidden
        self.avatarImageView.isHidden = !hidden
        self.statusView.isHidden = !hidden
    }

//MARK: - ConfigureWithPrivateCannel
    fileprivate func configureCellWithPrivateChannel(_ channel: Channel)  {
        configureNameChannelLabelTextForChannel(true, channel: channel)
        configureDateLabelText(channel)
        configureAvatarImageView(channel)
        configureLastPostLabelTextForPrivateChannel(channel)
        configureStatusView(channel)
    }
    
//MARK: - ConfigureWithPublicChannel
    fileprivate func configureCellWithPublicChannel(_ channel: Channel) {
        configureNameChannelLabelTextForChannel(false, channel: channel)
        configureDateLabelText(channel)
        configureLastPostLabelTextForPublicChannel(channel)
        configureAvatarViewForPublicChannel()
        configureLetterFirstNamesChannelLabelText(channel)
    }
    
//MARK: - ConfigureTextLabel
    fileprivate func configureLastPostLabelTextForPrivateChannel(_ channel:Channel) {
        //self.lastPostLabel.text = channel.posts.last?.message
        let lastPost = try! Realm().objects(Post.self).filter("channelId = %@", channel.identifier!).last
        self.lastPostLabel.text = lastPost?.message
    }
    
    fileprivate func configureNameChannelLabelTextForChannel(_ isPrivate:Bool, channel: Channel){
        self.nameChannelLabel.text = isPrivate ? "@" + channel.displayName! : "#" + channel.displayName!
    }
    
    fileprivate func configureDateLabelText(_ channel: Channel) {
        self.dateLabel.text = channel.lastViewDate?.messageDateFormatForChannel()
    }
    
    fileprivate func configureLastPostLabelTextForPublicChannel(_ channel:Channel){
        //self.lastPostLabel.text = channel.posts.last?.message
        let lastPost = try! Realm().objects(Post.self).filter("channelId = %@", channel.identifier!).last
        if lastPost == nil {
            self.avatarUsersLastPostImageView.isHidden = true
            self.lastPostLabel.text = ""
        } else {
            configureAvatarUsersLastPostImageView(lastPost!)
            self.lastPostLabel.text = lastPost?.message
        }
        
    }
    
    fileprivate func configureLetterFirstNamesChannelLabelText(_ channel:Channel) {
        self.letterFirstNamesChannelLabel.text = channel.displayName![0]
    }

//MARK: - ConfigureAvatarView
    fileprivate func configureAvatarViewForPublicChannel() {
        self.avatarView.backgroundColor = ColorBucket.blueColor
        self.letterFirstNamesChannelLabel.backgroundColor = ColorBucket.blueColor
        self.letterFirstNamesChannelLabel.textColor = ColorBucket.whiteColor
    }
 
//MARK: - ConfigureStatusUser
    fileprivate func configureStatusView(_ channel: Channel) {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(channel.interlocuterFromPrivateChannel().identifier).backendStatus
        configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    fileprivate func configureStatusViewWithBackendStatus(_ backendStatus: String) {
        switch backendStatus {
            case "online":
                self.statusView.backgroundColor = ColorBucket.onlineStatusColor
            case "away":
                self.statusView.backgroundColor = ColorBucket.awayStatusColor
            default:
                self.statusView.isHidden = true
        }
    }

//MARK: - ConfigureImageView
    fileprivate func configureAvatarImageView (_ channel: Channel) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        let user = channel.interlocuterFromPrivateChannel()
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
    }
    
    fileprivate func configureAvatarUsersLastPostImageView(_ lastPost: Post) {
        self.avatarUsersLastPostImageView.image = UIImage.sharedFeedSystemAvatar
        let user = lastPost.author
        ImageDownloader.downloadFeedAvatarForUser(user!) { [weak self] (image, error) in
            self?.avatarUsersLastPostImageView.image = image
        }
    }
}
