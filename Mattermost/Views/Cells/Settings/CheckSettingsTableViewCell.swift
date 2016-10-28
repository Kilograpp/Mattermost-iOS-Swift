//
//  CheckSettingsTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CheckSettingsTableViewCell: UITableViewCell {

//MARK: Properties
    
    @IBOutlet weak var checkBoxButton: UIButton?
    
    var checkBoxHandler : (() -> Void)?
}


private protocol CheckSettingsTableViewCellLifeCycle {
    func awakeFromNib()
    func setSelected(_ selected: Bool, animated: Bool)
}

private protocol CheckSettingsTableViewCellSetup {
    func initialSetup()
    func setupCheckBoxButton()
}

private protocol CheckSettingsTableViewCellAction {
    func checkBoxAction()
}


//MARK: CheckSettingsTableViewCellLifeCycle

extension CheckSettingsTableViewCell: CheckSettingsTableViewCellLifeCycle {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


//MARK: CheckSettingsTableViewCellSetup

extension CheckSettingsTableViewCell: CheckSettingsTableViewCellSetup {
    func initialSetup() {
        setupCheckBoxButton()
    }
    
    func setupCheckBoxButton() {
        self.checkBoxButton?.backgroundColor = ColorBucket.whiteColor
        self.checkBoxButton?.layer.cornerRadius = Constants.UI.DoublePaddingSize / 2
        self.checkBoxButton?.layer.borderColor = ColorBucket.checkButtonBorderColor.cgColor
        self.checkBoxButton?.layer.borderWidth = 1
        self.checkBoxButton?.layer.masksToBounds = true
        self.checkBoxButton?.setImage(UIImage(named: "check_blue"), for: .selected)
        self.checkBoxButton?.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
    }
}


//MARK: CheckSettingsTableViewCellAction

extension CheckSettingsTableViewCell: CheckSettingsTableViewCellAction {
    func checkBoxAction() {
        self.checkBoxButton?.isSelected = !(self.checkBoxButton?.isSelected)!
        if (self.checkBoxHandler != nil) {
            self.checkBoxHandler!()
        }
    }
}
