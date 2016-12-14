//
//  CreateChannelNameCell.swift
//  Mattermost
//
//  Created by Владислав on 13.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CreateChannelNameCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var channelFirstSymbol: UILabel!
    var field: ChannelCreateField!
    let limitLength = 22
    var delgate : CellUpdated?
    
    @IBAction func deleteTextAction(_ sender: AnyObject) {
        textField.text = ""
        if let iuDelegate = self.delgate {
            iuDelegate.cellUpdated(text: "")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelFirstSymbol.layer.cornerRadius = 30.0
        channelFirstSymbol.clipsToBounds = true
        
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
        channelFirstSymbol.text = String(field.value[0])
        if let iuDelegate = self.delgate {
            iuDelegate.cellUpdated(text: "")
        }
    }
}
