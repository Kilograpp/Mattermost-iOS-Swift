//
//  LabelChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(text: String, color: UIColor)
}

class LabelChannelSettingsCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    
}


//MARK: Interface
extension LabelChannelSettingsCell: Interface {
    static func cellHeight() -> CGFloat {
        return 56
    }
    
    func configureWith(text: String, color: UIColor) {
        self.titleLabel.text = text
        self.titleLabel.textColor = color
    }
}
