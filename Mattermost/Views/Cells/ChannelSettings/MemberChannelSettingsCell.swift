//
//  MemberChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(user: User)
}

class MemberChannelSettingsCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var user: User!
    
//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    func configureStatusViewWithNotification(_ notification: Notification) {
        configureUserStatusWith(notification.object as! String)
    }
}


//MARK: Interface
extension MemberChannelSettingsCell: Interface {
    static func cellHeight() -> CGFloat { return 50 }
    
    func configureWith(user: User) {
        self.user = user
        
        self.nameLabel.text = user.username
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        
        configureUserStatusWith(UserStatusObserver.sharedObserver.statusForUserWithIdentifier(user.identifier).backendStatus!)
        subscribeToNotifications()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupAvatarImageView()
    func subscribeToNotifications()
}

fileprivate protocol Configuration: class {
    func updateUserStatusWith(_ notification: Notification)
    func configureUserStatusWith(_ backendStatus: String)
    func reloadCell()
}


//MARK: Setup
extension MemberChannelSettingsCell: Setup {
    func initialSetup() {
        setupAvatarImageView()
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.layer.cornerRadius = 20.0
        self.avatarImageView.clipsToBounds = true
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserStatusWith(_:)),
                                               name: NSNotification.Name((user.identifier)!), object: nil)
    }
}


//MARK: Configuration
extension MemberChannelSettingsCell: Configuration {
    func updateUserStatusWith(_ notification: Notification) {
        configureUserStatusWith(notification.object as! String)
    }
    
    func configureUserStatusWith(_ backendStatus: String) {
        print("stats = ", backendStatus)
        switch backendStatus {
        case "online":
            self.statusLabel.textColor = ColorBucket.onlineStatusColor
            self.statusLabel.text = backendStatus
        case "away":
            self.statusLabel.textColor = ColorBucket.offlineStatusColor
            self.statusLabel.text = backendStatus
        case "offline":
            self.statusLabel.textColor = ColorBucket.offlineStatusColor
            self.statusLabel.text = backendStatus
        default:
            break
        }
    }
    
    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(user.identifier).backendStatus
        configureUserStatusWith(backendStatus!)
    }
}
