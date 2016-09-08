//
//  ChannelHeaderViewController.swift
//  Mattermost
//
//  Created by Tatiana on 08/09/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ChannelHeaderViewController : UIViewController {
   
    @IBOutlet weak var textField: UITextField!
    
    var channel : Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupTextField()
        SetupRightButton()
        
    }
}

private protocol Setup {
    func setupTextField()
    func setupTitle()
    func SetupRightButton()
}

extension ChannelHeaderViewController : Setup {
    func setupTextField() {
        self.textField.clearButtonMode = .Always
        self.textField.text = self.channel?.header
    }
    
    func setupTitle() {
        self.title = "Channel Header"
    }
    
    func SetupRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(save))
    }
}

private protocol Private {
    func save()
}

extension ChannelHeaderViewController : Private {
    func save() {
        
    }
}