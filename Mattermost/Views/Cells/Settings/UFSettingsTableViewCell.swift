//
//  UFSettingsTableViewCell.swift
//  Mattermost
//
//  Created by Екатерина on 27.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class UFSettingsTableViewCell: UITableViewCell {

//MARK: Properties
    @IBOutlet weak var infoTextField: UITextField?
    
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
