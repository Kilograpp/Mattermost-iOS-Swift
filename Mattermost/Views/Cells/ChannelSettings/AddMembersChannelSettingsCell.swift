//
//  AddMembersChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
}


class AddMembersChannelSettingsCell: UITableViewCell, Reusable {
}


//Interface
extension AddMembersChannelSettingsCell: Interface {
    static func cellHeight() -> CGFloat { return 50 }
}
