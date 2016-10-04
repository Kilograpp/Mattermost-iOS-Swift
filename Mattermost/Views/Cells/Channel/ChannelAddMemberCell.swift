//
//  ChannelAddMemberCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

// blue
final class ChannelAddMemberCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupTextColor()
        textLabel?.text = "Test"
    }
    func setupTextColor() {
        textLabel?.textColor = ColorBucket.blueColor
    }
    func configureWithObject(object: ChannelInfoCellObject) {
        let data = object as! TitleWithImageData
        textLabel!.text = data.title
        imageView?.image = data.image
    }
}