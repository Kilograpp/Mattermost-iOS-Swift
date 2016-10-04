//
//  ChannelTitleTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ChannelTitleTableViewCell: UITableViewCell, Reusable {
    
    func configureWithObject(object: ChannelInfoCellObject) {
        let title = object as! String
        textLabel!.text = title
    }
    
    
}