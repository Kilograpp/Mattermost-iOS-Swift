//
//  ChannelMemberTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ChannelMemberTableViewCell: UITableViewCell, Reusable {
    
    func configureWithObject(object: ChannelInfoCellObject) {
        let user = object as! User
        textLabel!.text = user.displayName
        ImageDownloader.downloadFeedAvatarForUser(user, completion: { (image, error) in
            self.imageView?.image = image
        })
        // status : discView
    }
}