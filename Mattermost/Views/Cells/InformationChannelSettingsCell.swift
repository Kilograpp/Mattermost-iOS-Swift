//
//  InformationChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
//Нужен ли ксиб?
class InformationChannelSettingsCell: UITableViewCell {

    @IBOutlet weak var infoName: UILabel!
    @IBOutlet weak var infoDetail: UILabel! {
        didSet { isCopyEnabled = false }
    }
    
    var isCopyEnabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupGestureRecognizers()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

fileprivate protocol Setup {
    func setupGestureRecognizers()
}

fileprivate protocol Action: class {
    func longPressAction(recognizer:UILongPressGestureRecognizer)
}


//MARK: Setup
extension InformationChannelSettingsCell: Setup {
    func setupGestureRecognizers() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(recognizer:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longPress)
    }
}


//MARK: Action
extension InformationChannelSettingsCell: Action {
    func longPressAction(recognizer:UILongPressGestureRecognizer) {
        guard self.isCopyEnabled else { return }
        guard recognizer.state == .ended else { return }
        
        UIPasteboard.general.string = self.infoDetail?.text
        AlertManager.sharedManager.showSuccesWithMessage(message: "Information was copied to clipboard")
    }
}

