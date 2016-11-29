//
//  MemberChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class MemberChannelSettingsCell: UITableViewCell {
//CODEREVIEW: Точно нужен для этой простой ячейки ксиб
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberStatus: UILabel!
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memberImage.layer.cornerRadius = 20.0
        memberImage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureStatusViewWithNotification(_ notification: Notification) {
        setupStatusViewWithBackendStatus(notification.object as! String)
    }
}

extension MemberChannelSettingsCell {
    func configureWithUser(user: User) {
        self.user = user
        memberName.text = user.displayName
        memberImage.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.memberImage.image = image
        }
        
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(user.identifier).backendStatus
        setupStatusViewWithBackendStatus(backendStatus!)
        
        subscribeToNotifications()
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configureStatusViewWithNotification(_:)),
                                               name: NSNotification.Name((user.identifier)!),
                                               object: nil)
    }
    
    func reloadCell() {
        let backendStatus = UserStatusObserver.sharedObserver.statusForUserWithIdentifier(user.identifier).backendStatus
        setupStatusViewWithBackendStatus(backendStatus!)
    }
        
    func setupStatusViewWithBackendStatus(_ backendStatus: String) {
        switch backendStatus {
        case "online":
            self.memberStatus.textColor = UIColor.kg_blueColor()
            self.memberStatus.text = backendStatus
        case "away":
            self.memberStatus.textColor = UIColor.lightGray
            self.memberStatus.text = backendStatus
            break // Зачем тут break?
        default:
            break
        }
    }
}
