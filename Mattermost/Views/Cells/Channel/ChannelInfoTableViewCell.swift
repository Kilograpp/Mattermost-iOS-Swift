//
//  ChannelInfoTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
// >
final class ChannelInfoTableViewCell: UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupAccessoryType()
        textLabel?.text = "Test"
        detailTextLabel!.text = "TestDetail"
    }
    func setupAccessoryType() {
        self.accessoryType = .DetailButton
    }
    func configureWithObject(object: ChannelInfoCellObject) {
        let channelInfo = object as! TitleWithDetailData
        textLabel!.text = channelInfo.title
        detailTextLabel!.text = channelInfo.detail
    }
}