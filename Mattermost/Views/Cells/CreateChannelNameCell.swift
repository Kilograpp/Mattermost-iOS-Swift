//
//  CreateChannelNameCell.swift
//  Mattermost
//
//  Created by Владислав on 13.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CreateChannelNameCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var channelFirstSymbol: UILabel!
    var field: ChannelCreateField!
    var handleField : ChannelCreateField!
    let limitLength = 22
    var delegate : CellUpdated?
    
    @IBAction func deleteTextAction(_ sender: Any) {
        textField.text = ""
        field.value = ""
        channelFirstSymbol.text = ""
        placeholder.isHidden = false
        if let iuDelegate = self.delegate {
            iuDelegate.cellUpdated(text: "")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelFirstSymbol.layer.cornerRadius = 30.0
        channelFirstSymbol.clipsToBounds = true
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupPlaceholder()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        placeholder.text = field.placeholder
        // Configure the view for the selected state
    }
    
    func setupPlaceholder() {
        if textField.text == "" {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= limitLength
    }
    
    func textFieldDidChange() {
        setupPlaceholder()
        if let text = textField.text {
            channelFirstSymbol.text = text.characters.count > 0 ? String(text[0]).uppercased() : ""
            field.value = text
            let theCFMutableString = NSMutableString(string: text) as CFMutableString
            _ = CFStringTransform(theCFMutableString, nil, kCFStringTransformToLatin, false)
            handleField.value = (theCFMutableString as String).replacingOccurrences(of: " ", with: "-", options: NSString.CompareOptions.literal, range:nil)
        }
        if let iuDelegate = self.delegate {
            iuDelegate.cellUpdated(text: "")
        }
    }
}
