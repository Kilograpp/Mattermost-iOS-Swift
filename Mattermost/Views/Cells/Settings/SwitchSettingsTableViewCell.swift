//
//  SwitchSettingsTableViewCell.swift
//  Mattermost
//
//  Created by Екатерина on 28.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class SwitchSettingsTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var stateSwitch: UISwitch?
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
