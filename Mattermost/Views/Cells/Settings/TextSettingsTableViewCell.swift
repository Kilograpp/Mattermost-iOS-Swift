//
//  TextSettingsTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class TextSettingsTableViewCell: UITableViewCell {

//MARK: Properties
    
    @IBOutlet weak var wordsTextView: UITextView?
    @IBOutlet weak var placeholderLabel: UILabel?
    
}


private protocol TextSettingsTableViewCellLifeCycle {
    func awakeFromNib()
    func setSelected(_ selected: Bool, animated: Bool)
}


//MARK: TextSettingsTableViewCellLifeCycle

extension TextSettingsTableViewCell: TextSettingsTableViewCellLifeCycle {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
