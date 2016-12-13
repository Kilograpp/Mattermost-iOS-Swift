//
//  ChannelNameAndHandleCell.swift
//  Mattermost
//
//  Created by Владислав on 30.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol SetupSaveButton {
    func setupSaveButton(_ enable: Bool)
}

class ChannelNameAndHandleCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    let limitLength = 22
    var delgate : SetupSaveButton?

    @IBAction func deleteTextAction(_ sender: AnyObject) {
        textField.text = ""
        if let iuDelegate = self.delgate {
            iuDelegate.setupSaveButton(false)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= limitLength
    }
    
    func textFieldDidChange() {
        guard let text = textField.text else { return }
        if let iuDelegate = self.delgate {
            if text != ""{
                iuDelegate.setupSaveButton(true)
            } else {
                iuDelegate.setupSaveButton(false)
            }
        }
    }
}
