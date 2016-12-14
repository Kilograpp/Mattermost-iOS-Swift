//
//  ChannelInfoCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol CellUpdated {
    func cellUpdated(text: String)
}

class ChannelInfoCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoText: UITextView!
    var delgate : CellUpdated?
    
    @IBAction func deleteTextAction(_ sender: AnyObject) {
        infoText.text = ""
        if let iuDelegate = self.delgate {
            iuDelegate.cellUpdated(text: infoText.text)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoText.delegate = self
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupCancelButtonHidding()
        // Configure the view for the selected state
    }
    
    func textViewDidChange(_ textView: UITextView){
        setupCancelButtonHidding()
        if let iuDelegate = self.delgate {
            iuDelegate.cellUpdated(text: infoText.text)
        }
    }
    
    func setupCancelButtonHidding(){
        if ChannelInfoCell.heightWithObject(infoText.text) > 48.0{
            cancelButton.isHidden = true
        } else {
            cancelButton.isHidden = false
        }
    }
    
    static func heightWithObject(_ text: String) -> CGFloat{
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 69.0, height: CGFloat.greatestFiniteMagnitude)
        let size = text.boundingRect(with: maxSize,
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)],
                                     context: nil).size
        return size.height+30.0
    }
}

