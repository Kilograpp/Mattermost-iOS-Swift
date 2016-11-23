//
//  ChannelInfoCell.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ChannelInfoCell: UITableViewCell {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func heightWithObject(text: String) -> CGFloat {
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 16, height: CGFloat.greatestFiniteMagnitude)
        
        let size = text.boundingRect(with: maxSize,
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)],
                                     context: nil).size
        
        return size.height + 15
    }
}
