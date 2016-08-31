//
//  MoreChannelsTableViewCell.swift
//  Mattermost
//
//  Created by Mariya on 31.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

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

//MARK: Override
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCell()
    }
    
//MARK: Setup
    
    private func setupCell(){
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
    }
    
    private func setupNameChannelLabel(){
        self.nameChannelLabel.tintColor = ColorBucket.blackColor
        self.nameChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.nameChannelLabel.font = FontBucket.titleChannelFont
        self.nameChannelLabel.numberOfLines = 1
    }
    
    private func setupLastPostLabel(){
        self.lastPostLabel.tintColor = ColorBucket.blackColor
        self.lastPostLabel.backgroundColor = ColorBucket.whiteColor
        self.lastPostLabel.font = FontBucket.subtitleChannelFont
        self.lastPostLabel.numberOfLines = 2
    }
    
    private func setupDateLabel(){
        self.dateLabel.tintColor = ColorBucket.grayColor
        self.dateLabel.backgroundColor = ColorBucket.whiteColor
        self.dateLabel.font = FontBucket.dateChannelFont
    }
    
    private func setupAvatarUsersLastPostImageView(){
        self.avatarUsersLastPostImageView.layer.cornerRadius = self.avatarUsersLastPostImageView.bounds.height/2
        self.avatarUsersLastPostImageView.clipsToBounds = true
    }
    
    private func setupSeparatorView(){
        self.separatorView.backgroundColor = ColorBucket.grayColor
        self.separatorView.bounds.size.height = 0.7
    }
    
    private func setupLetterFirstNamesChannelLabel(){
        self.letterFirstNamesChannelLabel.backgroundColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.tintColor = ColorBucket.whiteColor
        self.letterFirstNamesChannelLabel.font = FontBucket.letterChannelFont
    }

}
