//
//  EmptyDialogueLabel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 17/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class EmptyDialogueLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    convenience init() {
        self.init(frame: .zero)
        configure()
    }
    
    private func configure() {
        self.text = "No messages in this\n channel yet"
        self.textAlignment = .center
        self.numberOfLines = 0
        self.font = FontBucket.feedbackTitleFont
        self.textColor = UIColor.black
        self.backgroundColor = self.superview?.backgroundColor
        self.frame = CGRect(x: 0, y: 0, width: 280, height: 60)
        self.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 100)
        self.isHidden = true
    }
}
