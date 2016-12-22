//
//  MemberInAdditingCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class MemberInAdditingCell: UITableViewCell {
    
    @IBOutlet weak var memberIcon: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memberIcon.layer.cornerRadius = 20.0
        memberIcon.clipsToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension MemberInAdditingCell {
    func configureWithUser(user: User) {
        memberName.text = user.username
        memberIcon.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.memberIcon.image = image
        }
    }
}
