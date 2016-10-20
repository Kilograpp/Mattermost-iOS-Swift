//
//  TeamTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol TeamTableViewCellConfiguration {
    func configureWithTeam(_ team:Team)
}

class TeamTableViewCell : UITableViewCell, Reusable {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: TeamTableViewCellConfiguration

extension TeamTableViewCell: TeamTableViewCellConfiguration {
    func configureWithTeam(_ team: Team) {
        self.textLabel?.text = team.displayName!
    }
}


private protocol TeamTableViewCellSetup {
    func initialSetup()
}


//MARK: TeamTableViewCellSetup

extension TeamTableViewCell: TeamTableViewCellSetup {
    func initialSetup() {
        accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        let width = UIScreen.screenWidth() - 2 * Constants.UI.StandardPaddingSize
        let frame = CGRect(x: Constants.UI.StandardPaddingSize, y: 59, width: width, height: 1)
        let separatorView = UIView(frame: frame)
        separatorView.backgroundColor = ColorBucket.rightMenuTextColor
        self.addSubview(separatorView)
    }
}
