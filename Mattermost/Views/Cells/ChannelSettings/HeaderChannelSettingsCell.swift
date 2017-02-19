//
//  HeaderChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(channelName: String)
}

class HeaderChannelSettingsCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var firstCharacterLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    

//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
}


//MARK: Interface
extension HeaderChannelSettingsCell: Interface {
    func configureWith(channelName: String) {
        self.nameLabel.text = channelName
        self.firstCharacterLabel.text = String(channelName.characters.prefix(1)).capitalized
    }
    
    static func cellHeight() -> CGFloat {
        return 91
    }
}


fileprivate protocol Setup: class {
    func initialSetup();
    func setupIconImageView()
}


//MARK: Setup
extension HeaderChannelSettingsCell: Setup {
    func initialSetup() {
        setupIconImageView()
    }
    
    func setupIconImageView() {
        self.iconImageView.layer.cornerRadius = 30.0
        self.iconImageView.clipsToBounds = true
    }
}
