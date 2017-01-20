//
//  DirectChannelTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 19.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

final class DirectChannelTableViewCell: UITableViewCell {

//MARK: Properties
    
    @IBOutlet fileprivate weak var statusView: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var badgeLabel: UILabel!
    @IBOutlet fileprivate weak var highlightView: UIView!

    var channel : Channel?
    var test : (() -> Void)?
    fileprivate var user : User!
    fileprivate var userBackendStatus: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.highlightView.backgroundColor = highlighted ? ColorBucket.whiteColor.withAlphaComponent(0.5) : self.highlightViewBackgroundColor()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeObservers()
    }
    
    func configureStatusViewWithNotification(_ notification: Notification) {
        setupStatusViewWithBackendStatus(notification.object as! String)
    }
}

private protocol DirectChannelTableViewCellSetup {
    func initialSetup()
    func setupContentView()
    func setupTitleLabel()
    func setupStatusView()
    func setupHighlightView()
    func setupUserFormPrivateChannel()
    func setupBadgeLabel()
    func setupStatusViewWithBackendStatus(_ backendStatus: String)
    func highlightViewBackgroundColor() -> UIColor
}


//MARK: LeftMenuTableViewCellProtocol

extension DirectChannelTableViewCell: LeftMenuTableViewCellProtocol {
    func configureWithChannel(_ channel: Channel, selected: Bool) {
        self.channel = channel
        setupUserFormPrivateChannel()
        subscribeToNotifications()
        self.titleLabel.text = channel.displayName!
        
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        setupStatusViewWithBackendStatus(backendStatus!)
        
        badgeLabel.isHidden = (channel.mentionsCount==0)
        badgeLabel.text = String(channel.mentionsCount)
        badgeLabel.font = FontBucket.normalTitleFont

        self.highlightView.backgroundColor = selected ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
        self.titleLabel.font = (channel.hasNewMessages()) ? FontBucket.highlighTedTitleFont : FontBucket.normalTitleFont
        if selected {
            self.titleLabel.textColor =  (channel.hasNewMessages()) ? ColorBucket.blackColor : ColorBucket.sideMenuSelectedTextColor
        } else {
            self.titleLabel.textColor = (channel.hasNewMessages()) ? ColorBucket.whiteColor : ColorBucket.sideMenuCommonTextColor
        }
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configureStatusViewWithNotification(_:)),
                                               name: NSNotification.Name((self.channel?.interlocuterFromPrivateChannel().identifier)!),
                                               object: nil)
    }

    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(self.channel!.interlocuterFromPrivateChannel().identifier).backendStatus
        setupStatusViewWithBackendStatus(backendStatus!)
    }
}


//MARK: Setup

extension DirectChannelTableViewCell: DirectChannelTableViewCellSetup {
    func initialSetup() {
        setupContentView()
        setupTitleLabel()
        setupStatusView()
        setupHighlightView()
        setupBadgeLabel()
    }
    
    func setupContentView() {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.sideMenuCommonTextColor
    }
    
    func setupStatusView() {
        self.statusView.layer.cornerRadius = 4
        self.statusView.layer.borderColor = ColorBucket.lightGrayColor.cgColor
        self.statusView.layer.borderWidth = 1;
    }
    
    func setupBadgeLabel() {
        badgeLabel.layer.cornerRadius = 10;
    }
    
    func setupHighlightView() {
        self.highlightView.layer.cornerRadius = 3;
    }
    
    func setupUserFormPrivateChannel() {
        self.user = self.channel?.interlocuterFromPrivateChannel()
    }
    
    func setupStatusViewWithBackendStatus(_ backendStatus: String) {
        switch backendStatus {
        case "offline":
            self.statusView.backgroundColor = UIColor.clear
            self.statusView.layer.borderWidth = 1
            break
        case "online":
            self.statusView.backgroundColor = UIColor.green
            self.statusView.layer.borderWidth = 0
            break
        case "away":
            self.statusView.backgroundColor = UIColor.yellow
            self.statusView.layer.borderWidth = 0
            break
        default:
            self.statusView.backgroundColor = UIColor.black
            self.statusView.layer.borderWidth = 0
            break
        }
    }
    
    func highlightViewBackgroundColor() -> UIColor {
        return self.channel?.isSelected == true ? ColorBucket.sideMenuCellSelectedColor : ColorBucket.sideMenuBackgroundColor
    }
}

