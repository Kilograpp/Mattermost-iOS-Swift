//
//  EmptyDialogueLabel.swift
//  Mattermost
//
//  Created by Maxim Gubin on 17/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class EmptyDialogueLabel: UILabel {
    var channel: Channel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureNoMessages()
    }
    
    convenience init() {
        self.init(frame: .zero)
        channel = nil
        configureNoMessages()
    }
    
    convenience init(channel: Channel, type: Int) {
        self.init(frame: .zero)
        self.channel = channel
        configureStartDialogWith(type: type)
    }
    
    private func configureNoMessages() {
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
    
    private func configureStartDialogWith(type: Int) {
        switch (type) {
        case 0:
            self.text = "Beginning of \(channel.displayName!)"
            //FORNEW
            self.font = FontBucket.feedbackTitleFont
            self.frame = CGRect(x       : 0,
                                y       : 0,
                                width   : UIScreen.main.bounds.size.width*0.90,
                                height  : 60)
            self.center = CGPoint(x: UIScreen.main.bounds.size.width / 2,
                                  y: UIScreen.main.bounds.size.height / 2.5)
        default:
            if channel.privateType! == "P" {
                self.text = "This is the start of the \(channel.displayName!) private group, created on \(channel.createdAt!.startDialogDateFormat()). Only invited members can see this private group."
            } else if channel.privateType! == "D" {
                self.text = "This is the start of your direct message history with \(channel.displayName!).\n\nDirect messages and files shared here are not shown to people outside this area."
            } else {
                self.text = "This is the start of the \(channel.displayName!) channel, created on \(channel.createdAt!.startDialogDateFormat()). Any member can join and read this channel."
            }
            //FORNEW
            self.font = FontBucket.feedbackTitleFont.withSize(13.5)
            self.frame = CGRect(x       : 0,
                                y       : 0,
                                width   : UIScreen.main.bounds.size.width*0.90,
                                height  : 90)
            self.center = CGPoint(x: UIScreen.main.bounds.size.width / 2,
                                  y: UIScreen.main.bounds.size.height / 1.95)
        }
        self.textAlignment = .left
        self.numberOfLines = 0
        self.textColor = UIColor.black
        self.backgroundColor = self.superview?.backgroundColor
        self.isHidden = true
    }
}
