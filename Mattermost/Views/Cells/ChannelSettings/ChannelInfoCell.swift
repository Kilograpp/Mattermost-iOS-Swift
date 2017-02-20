//
//  ChannelInfoCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

fileprivate let maxTextHeight: CGFloat = 396

enum InfoType: String{
    case header  = "header"
    case purpose = "purpose"
}

protocol ChannelInfoCellDelegate {
    func cellWasUpdatedWith(text: String, height: CGFloat)
}

private protocol Interface: class {
    static func heightWith(text: String) -> CGFloat
    func configureWith(delegate: ChannelInfoCellDelegate)
    func configureWith(delegate: ChannelInfoCellDelegate, text: String, infoType: InfoType)
    func configureWith(delegate: ChannelInfoCellDelegate, placeholderText: String)
    func hideKeyboardIfNeeded()
    func updateWith(text: String)
}

class ChannelInfoCell: UITableViewCell {
    
//MARK: Properties
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var placeholderLabel: UILabel!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    
    fileprivate var delegate: ChannelInfoCellDelegate?
    fileprivate var infoType: InfoType?
    
    var field: ChannelCreateField!
    var isHandlerCell = false
    
    var infoText: String { return self.textView.text }
}


//MARK: Interface
extension ChannelInfoCell: Interface {
    static func heightWith(text: String) -> CGFloat{
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 69, height: CGFloat.greatestFiniteMagnitude)
        let size = text.boundingRect(with: maxSize,
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: [NSFontAttributeName: FontBucket.infoTextFont],
                                     context: nil).size
        return size.height + 30
    }
    
    func configureWith(delegate: ChannelInfoCellDelegate) {
        self.delegate = delegate
    }
    
    func configureWith(delegate: ChannelInfoCellDelegate, text: String, infoType: InfoType) {
        self.delegate = delegate
        self.textView.text = text
        
        self.placeholderLabel.text = "Enter " + infoType.rawValue
        self.placeholderLabel.isHidden = !text.isEmpty
    }
    
    internal func configureWith(delegate: ChannelInfoCellDelegate, placeholderText: String) {
        self.delegate = delegate
        self.textView.text = ""
        
        self.placeholderLabel.text = placeholderText
        self.placeholderLabel.isHidden = false
    }
    
    func hideKeyboardIfNeeded() {
        self.textView.resignFirstResponder()
    }
    
    func updateWith(text: String) {
        self.textView.text = text
        self.placeholderLabel.isHidden = !text.isEmpty
        guard self.delegate != nil else { return }
        
        self.delegate?.cellWasUpdatedWith(text: "", height: ChannelInfoCell.heightWith(text: text))
    }
}


fileprivate protocol Action: class {
    func clearAction()
}


//MARK: Action
extension ChannelInfoCell: Action {
    @IBAction func clearAction() {
        self.textView.text = ""
        self.placeholderLabel.isHidden = false
        self.cancelButton.isHidden = true
        let newHeight = ChannelInfoCell.heightWith(text: "")
        self.delegate?.cellWasUpdatedWith(text: "", height: newHeight)
    }
}


//MARK: TextViewDelegate
extension ChannelInfoCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if ((self.infoType == InfoType.header) && (text == " ")) { return false }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let newHeight = ChannelInfoCell.heightWith(text: newText)
        self.placeholderLabel.isHidden = !newText.isEmpty
        self.cancelButton.isHidden = newText.isEmpty
        if newHeight <= maxTextHeight {
            self.delegate?.cellWasUpdatedWith(text: "", height: newHeight)
            textView.text = newText
        }
        
        return false
    }
}

