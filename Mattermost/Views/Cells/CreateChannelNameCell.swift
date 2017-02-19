//
//  CreateChannelNameCell.swift
//  Mattermost
//
//  Created by Владислав on 13.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

let maxTextLength = 22

protocol CreateChannelNameCellDelegate {
    func cellWasUpdatedWith(text: String, height: CGFloat)
}

private protocol Interface: class {
    static func cellHeight() -> CGFloat
    func configureWith(placeholderText: String)
    func highligthError()
}

class CreateChannelNameCell: UITableViewCell {

//MARK: Properties
    @IBOutlet weak var firstCharacterLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    
    var delegate : CreateChannelNameCellDelegate?
    
    var localizatedName = String()
    

//MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()

        initialSetup()
    }
}


//MARK: Interface
extension CreateChannelNameCell: Interface {
    static func cellHeight() -> CGFloat {
        return 90
    }
    
    func configureWith(placeholderText: String) {
        self.placeholderLabel.text = placeholderText
    }
    
    func highligthError() {
        self.placeholderLabel.textColor = ColorBucket.errorAlertColor
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupFirstCharacterLabel()
}

fileprivate protocol Action: class {
    func clearAction()
}


//MARK: Setup
extension CreateChannelNameCell: Setup {
    func initialSetup() {
        setupFirstCharacterLabel()
    }
    
    func setupFirstCharacterLabel() {
        self.firstCharacterLabel.layer.cornerRadius = 30.0
        self.firstCharacterLabel.clipsToBounds = true
    }
}


//MARK: Action
extension CreateChannelNameCell: Action {
    @IBAction func clearAction() {
        self.firstCharacterLabel.text = ""
        self.textField.text = ""
        self.placeholderLabel.isHidden = false
        self.clearButton.isHidden = true
        
        self.delegate?.cellWasUpdatedWith(text: self.textField.text!, height: 0)
    }
}


//MARK: UITextFieldDelegate
extension CreateChannelNameCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        self.placeholderLabel.textColor = ColorBucket.lightGrayColor
        var newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let localizatedString = NSMutableString(string: newString.replacingOccurrences(of: " ", with: "-"))
        CFStringTransform(localizatedString, nil, kCFStringTransformToLatin, false)
        
        self.firstCharacterLabel.text = !newString.isEmpty ? String(newString.characters.prefix(1)).capitalized : ""
        self.placeholderLabel.isHidden = !newString.isEmpty
        self.clearButton.isHidden = newString.isEmpty
        if newString.characters.count <= limitLength { self.localizatedName = localizatedString as String }
        
        return newString.characters.count <= limitLength
    }
}
