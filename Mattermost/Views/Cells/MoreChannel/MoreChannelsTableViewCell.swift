//
//  MoreChannelsTableViewCell.swift
//  Mattermost
//
//  Created by Mariya on 31.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol PublicMoreChannels : class {
    static func nib () -> (UINib)
    static func reuseIdentifier () -> (String)
    static func height()->(CGFloat)
}

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

private protocol Configure : class {
    func configureCellWithObject(channel: Channel)
}


final class MoreChannelsTableViewCell: UITableViewCell {

//MARK: property
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var letterFirstNamesChannelLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var nameChannelLabel: UILabel!
    @IBOutlet weak var lastPostLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarUsersLastPostImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    private let privateTypeChannel = "D"
    private let publicTypeChannel = "O"

//MARK: Override
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


//MARK: PublicMoreChannels
extension MoreChannelsTableViewCell: PublicMoreChannels {
    class func nib () -> (UINib){
        return UINib(nibName: "MoreChannelsTableViewCell", bundle: nil)
    }
    
    class func reuseIdentifier () -> (String) {
        return "MoreChannelsTableViewCell" + "Identifier"
    }
    
    class func height()->(CGFloat) {
        return 80
    }
}

//MARK: Setup
extension MoreChannelsTableViewCell : Setup {
    
    private func setupAvatarView(){
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height/2
        self.avatarView.backgroundColor = ColorBucket.whiteColor
        
    }
    
    private func setupAvatarImageView(){
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height/2
        self.avatarImageView.clipsToBounds = true
    }
    
    private func setupStatusView() {
        self.statusView.layer.cornerRadius = self.statusView.bounds.height/2
        self.statusView.layer.borderWidth = 2
        self.statusView.layer.borderColor = ColorBucket.whiteColor.CGColor
        self.statusView.backgroundColor = ColorBucket.darkGrayColor
        self.avatarView.bringSubviewToFront(self.statusView)
    }
    
    private func setupNameChannelLabel(){
        self.nameChannelLabel.textColor = ColorBucket.blackColor
        self.nameChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.nameChannelLabel.font = FontBucket.titleChannelFont
        self.nameChannelLabel.numberOfLines = 1
    }
    
    private func setupLastPostLabel(){
        self.lastPostLabel.textColor = ColorBucket.blackColor
        self.lastPostLabel.backgroundColor = ColorBucket.whiteColor
        self.lastPostLabel.font = FontBucket.subtitleChannelFont
        self.lastPostLabel.numberOfLines = 2
    }
    
    private func setupDateLabel(){
        self.dateLabel.textColor = ColorBucket.grayColor
        self.dateLabel.backgroundColor = ColorBucket.whiteColor
        self.dateLabel.font = FontBucket.dateChannelFont
    }
    
    private func setupAvatarUsersLastPostImageView(){
        self.avatarUsersLastPostImageView.layer.cornerRadius = self.avatarUsersLastPostImageView.bounds.height/2
        self.avatarUsersLastPostImageView.clipsToBounds = true
    }
    
    private func setupSeparatorView(){
        self.separatorView.backgroundColor = ColorBucket.rightMenuSeparatorColor
    }
    
    private func setupLetterFirstNamesChannelLabel(){
        self.letterFirstNamesChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.tintColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.font = FontBucket.letterChannelFont
    }
}

extension MoreChannelsTableViewCell : Configure {

//MARK: ConfigureCell
    func configureCellWithObject(channel: Channel) {
        if channel.privateType == privateTypeChannel {
            configureHiddenForSubviews(true)
            configureCellWithPrivateChannel(channel)
        }
        if channel.privateType == publicTypeChannel  {
            configureHiddenForSubviews(false)
            configureCellWithPublicChannel(channel)
        }
    }
    
    private func configureHiddenForSubviews(hidden: Bool) {
        self.letterFirstNamesChannelLabel.hidden = hidden
        self.avatarUsersLastPostImageView.hidden = hidden
        self.avatarImageView.hidden = !hidden
        self.statusView.hidden = !hidden
    }

//MARK: ConfigureWithPrivateCannel
    private func configureCellWithPrivateChannel(channel: Channel)  {
        configureNameChannelLabelTextForChannel(true, channel: channel)
        configureDateLabelText(channel)
        configureAvatarImageView(channel)
        configureLastPostLabelTextForPrivateChannel(channel)
        configureStatusView(channel)
    }
    
//MARK: ConfigureWithPublicChannel
    private func configureCellWithPublicChannel(channel: Channel) {
        configureNameChannelLabelTextForChannel(false, channel: channel)
        configureDateLabelText(channel)
        configureLastPostLabelTextForPublicChannel(channel)
        configureAvatarViewForPublicChannel()
        configureLetterFirstNamesChannelLabelText(channel)
    }
    
//MARK: ConfigureTextLabel
    private func configureLastPostLabelTextForPrivateChannel(channel:Channel) {
        //self.lastPostLabel.text = channel.posts.last?.message
        let lastPost = try! Realm().objects(Post).filter("channelId = %@", channel.identifier!).last
        self.lastPostLabel.text = lastPost?.message
    }
    
    private func configureNameChannelLabelTextForChannel(isPrivate:Bool, channel: Channel){
        self.nameChannelLabel.text = isPrivate ? "@" + channel.displayName! : "#" + channel.displayName!
    }
    
    private func configureDateLabelText(channel: Channel) {
        self.dateLabel.text = channel.lastViewDate?.messageDateFormatForChannel()
    }
    
    private func configureLastPostLabelTextForPublicChannel(channel:Channel){
        //self.lastPostLabel.text = channel.posts.last?.message
        let lastPost = try! Realm().objects(Post).filter("channelId = %@", channel.identifier!).last
        if lastPost == nil {
            self.avatarUsersLastPostImageView.hidden = true
            self.lastPostLabel.text = ""
        } else {
            configureAvatarUsersLastPostImageView(lastPost!)
            self.lastPostLabel.text = lastPost?.message
        }
        
    }
    
    private func configureLetterFirstNamesChannelLabelText(channel:Channel) {
        self.letterFirstNamesChannelLabel.text = channel.displayName![0]
    }

//MARK: ConfigureAvatarView
    private func configureAvatarViewForPublicChannel() {
        self.avatarView.backgroundColor = ColorBucket.blueColor
        self.letterFirstNamesChannelLabel.backgroundColor = ColorBucket.blueColor
        self.letterFirstNamesChannelLabel.textColor = ColorBucket.whiteColor
    }
 
//MARK: ConfigureStatusUser
    private func configureStatusView(channel: Channel) {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(channel.interlocuterFromPrivateChannel().identifier).backendStatus
        configureStatusViewWithBackendStatus(backendStatus!)
    }
    
    private func configureStatusViewWithBackendStatus(backendStatus: String) {
        switch backendStatus {
            case "online":
                self.statusView.backgroundColor = UIColor.greenColor()
            case "away":
                self.statusView.backgroundColor = UIColor.yellowColor()
            default:
                self.statusView.hidden = true
        }
    }

//MARK: ConfigureImageView
    private func configureAvatarImageView (channel: Channel) {
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        let user = channel.interlocuterFromPrivateChannel()
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
    }
    
    private func configureAvatarUsersLastPostImageView(lastPost: Post) {
        self.avatarUsersLastPostImageView.image = UIImage.sharedFeedSystemAvatar
        let user = lastPost.author
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarUsersLastPostImageView.image = image
        }
    }
}
