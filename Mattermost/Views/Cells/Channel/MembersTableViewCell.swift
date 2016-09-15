//
//  MembersTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 15.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class MembersTableViewCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        setupNameLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private protocol Configuration: class {
    func configureWithMember(user:User, strategy:MembersStrategy)
}

private protocol Setup: class {
    func setupNameLabel()
}

//MARK: - Setup
extension MembersTableViewCell: Setup {
    func setupNameLabel() {
        textLabel?.font = FontBucket.postAuthorNameFont
    }
}
//MARK: - Configuration
extension MembersTableViewCell: Configuration {
    func configureWithMember(user:User, strategy:MembersStrategy) {
        // FIX White background in imageView !!!
        textLabel?.text = user.displayName
        accessoryView = UIImageView(image:strategy.imageForCellAccessoryViewWithUser(user))
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self!.imageView!.image = image
        }

    }
}