//
//  TeamTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class TeamTableViewCell : UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        setupGeneral()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private protocol Configuration: class {
    func configureWithTeam(team:Team)
}
private protocol Setup: class {
    func setupGeneral()
}

//MARK: - Setup
extension TeamTableViewCell: Setup {
    func setupGeneral() {
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
}
//MARK: - Configuration
extension TeamTableViewCell: Configuration {
    func configureWithTeam(team: Team) {
        self.textLabel?.text = team.displayName!
    }
}