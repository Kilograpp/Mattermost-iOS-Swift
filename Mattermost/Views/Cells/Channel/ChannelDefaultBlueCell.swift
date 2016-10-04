//
//  ChannelDefaultBlueCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

// Blue + Center
import Foundation

final class ChannelDefaultBlueCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        textLabel?.text = "Test"
    }
    func setupTitleLabel() {
        textLabel?.textColor = ColorBucket.blueColor
        textLabel?.textAlignment = .Center
    }
    
    func configureWithObject(object: ChannelInfoCellObject) {
        let title = object as! String
        textLabel!.text = title
    }
}