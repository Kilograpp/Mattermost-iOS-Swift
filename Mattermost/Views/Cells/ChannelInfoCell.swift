//
//  ChannelInfoCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol HeightForTextView {
    func heightOfTextView(height: CGFloat)
}

class ChannelInfoCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoText: UITextView!
    var delgate : HeightForTextView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoText.delegate = self
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func textViewDidChange(_ textView: UITextView){
        if let iuDelegate = self.delgate {
            iuDelegate.heightOfTextView(height: ChannelInfoCell.heightWithObject(infoText.text))
        }
    }
    
    static func heightWithObject(_ text: String) -> CGFloat{
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 59, height: CGFloat.greatestFiniteMagnitude)
        let size = text.boundingRect(with: maxSize,
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)],
                                        context: nil).size
        return size.height+30.0
    }
}
//
//
//
//
//
//
//
//
//
//
//
//
//

///

////
////
////
////
//
//
//
//
//
//
//
//
///

