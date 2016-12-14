//
//  CreateChannelHandleCell.swift
//  Mattermost
//
//  Created by Владислав on 14.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class CreateChannelHandleCell: CreateChannelHeaderAndPurposeCell {
    let limitLength = 22
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let string = textView.text else { return true }
        let newLength = string.characters.count + text.characters.count - range.length
        return newLength <= limitLength
    }
}
