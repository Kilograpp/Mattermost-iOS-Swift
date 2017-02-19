//
//  MemberInAdditingCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(user: User)
}

final class MemberInAdditingCell: UITableViewCell, Reusable {
   
//MARK: Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
}


//MARK: Interface
extension MemberInAdditingCell: Interface {
    static func cellHeight() -> CGFloat { return 50 }
    
    func configureWith(user: User) {
        self.nameLabel.text = user.username
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupAvatarImageView()
}


//MARK: Setup
extension MemberInAdditingCell: Setup {
    func initialSetup() {
        setupAvatarImageView()
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.layer.cornerRadius = 20.0
        self.avatarImageView.clipsToBounds = true
    }
}
