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
    @IBOutlet weak var clearButton: UIButton?
    
//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupWordsTextView()
}


fileprivate protocol Action: class {
    func clearAction()
}


//MARK: Action
extension TextSettingsTableViewCell: Action {
    @IBAction func clearAction() {
        self.wordsTextView?.text = ""
        self.wordsTextView?.delegate?.textViewDidChange!(self.wordsTextView!)
        self.placeholderLabel?.isHidden = false
        self.clearButton?.isHidden = true
    }
}
