//
//  ChannelPurposeViewController.swift
//  Mattermost
//
//  Created by Tatiana on 08/09/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ChannelPurposeViewController : UIViewController {
    
    @IBOutlet weak var textField: UITextField!
        var channel : Channel?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupTitle()
            setupTextField()
            setupRightButton()
            
        }
    }
    
    private protocol Setup {
        func setupTextField()
        func setupTitle()
        func setupRightButton()
    }
    
    extension ChannelPurposeViewController : Setup {
        func setupTextField() {
            self.textField.clearButtonMode = .Always
            self.textField.text = self.channel?.purpose
        }
        
        func setupTitle() {
            self.title = "Channel Purpose"
        }
        
        func setupRightButton() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(save))
        }
    }
    
    private protocol Private {
        func save()
    }
    
    extension ChannelPurposeViewController : Private {
        func save() {
            
        }
}