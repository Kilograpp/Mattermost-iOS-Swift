//
//  ChannelNameAndHandleCell.swift
//  Mattermost
//
//  Created by Владислав on 30.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ChannelNameAndHandleCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    let limitLength = 22

    @IBAction func deleteTextAction(_ sender: AnyObject) {
        textField.text = ""
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self

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
}
