//
//  CommonSettingsTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 03.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CommonSettingsTableViewCell: UITableViewCell {

//MARK: Properties
    
    @IBOutlet weak var descriptionLabel: UILabel?

//MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
