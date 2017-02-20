//
//  InformationChannelSettingsCell.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(name: String, detail: String, copyEnabled: Bool)
}

class InformationChannelSettingsCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel! {
        didSet { isCopyEnabled = false }
    }
    
    var isCopyEnabled = false
    
//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupGestureRecognizers()
    }
}


//MARK: Interface
extension InformationChannelSettingsCell: Interface {
    static func cellHeight() -> CGFloat {
        return 50
    }
    
    func configureWith(name: String, detail: String, copyEnabled: Bool) {
        self.nameLabel.text = name
        self.detailLabel.text = detail
        self.isCopyEnabled = copyEnabled
        self.accessoryType = copyEnabled ? .none : .disclosureIndicator 
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
        
        UIPasteboard.general.string = self.detailLabel?.text
        AlertManager.sharedManager.showSuccesWithMessage(message: "Information was copied to clipboard")
    }
}

