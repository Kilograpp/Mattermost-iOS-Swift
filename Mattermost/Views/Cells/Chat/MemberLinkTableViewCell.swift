//
//  MemberLinkTableViewCell.swift
//  Mattermost
//
//  Created by Владислав on 08.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class MemberLinkTableViewCell: UITableViewCell {

    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberFullName: UILabel!
    @IBOutlet weak var memberNickname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        memberImage.layer.cornerRadius = 10.0
        memberImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithUser(user: User) {
        memberNickname.text = "@"+user.username!
        memberImage.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFeedAvatarForUser(user) { [weak self] (image, error) in
            self?.memberImage.image = image
        }
        memberFullName.text = user.firstName!+" "+user.lastName!
    }
    
    func configureWithIndex(index: Int) {
        memberNickname.text = "@"+Constants.LinkCommands.name[index]
        memberFullName.text = Constants.LinkCommands.description[index]
        memberImage.image = UIImage(named: "about_kg_icon")
    }
}
