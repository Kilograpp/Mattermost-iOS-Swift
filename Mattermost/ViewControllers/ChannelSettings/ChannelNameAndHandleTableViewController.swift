//
//  ChannelNameAndHandleTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 13.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

let limitLength = 22

private protocol Interface: class {
    func configureWith(channelId: String)
}

class ChannelNameAndHandleTableViewController: UITableViewController {

//MARK: Properties
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var clearDisplayNameButton: UIButton!
    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var clearNameButton: UIButton!
    
    var saveButton: UIBarButtonItem!
    
    var channel: Channel!
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Interface
extension ChannelNameAndHandleTableViewController: Interface {
    func configureWith(channelId: String) {
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupNameSection()
    func setupDisplayNameSection()
    func setupGestureRecognizers()
}

fileprivate protocol Action: class {
    func saveAction()
    func clearDisplayNameAction()
    func clearNameAction()
    func tapAction()
}

fileprivate protocol Navigation: class {
    func returnToChannelSettings()
}

fileprivate protocol Request: class {
    func update()
}


//MARK: Setup
extension ChannelNameAndHandleTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupDisplayNameSection()
        setupNameSection()
        setupGestureRecognizers()
    }
    
    func setupNavigationBar() {
        self.title = (channel.privateType! == "P") ? "Group info".localized : "Channel info".localized
        self.saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupDisplayNameSection() {
        self.displayNameTextField.text = self.channel.displayName
        self.clearDisplayNameButton.isHidden = (self.displayNameTextField.text?.isEmpty)!
    }
    
    func setupNameSection() {
        self.nameTextFiled.text = self.channel.name
        self.nameTextFiled.isEnabled = channel.name! != "town-square"
        
        self.clearNameButton.isHidden = ((self.nameTextFiled.text?.isEmpty)! || channel.name! == "town-square")
    }

    func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
}


//MARK: Action
extension ChannelNameAndHandleTableViewController: Action {
    func saveAction() {
        guard !(self.displayNameTextField.text?.isEmpty)! else { self.handleErrorWith(message: "Incorrect name"); return }
        guard !(self.nameTextFiled.text?.isEmpty)! else { self.handleErrorWith(message: "Incorrect handle"); return }
        
        update()
    }
    
    @IBAction func clearDisplayNameAction() {
        self.saveButton.isEnabled = !(self.displayNameTextField.text?.isEmpty)!
        self.displayNameTextField.text = ""
    }
    
    @IBAction func clearNameAction() {
        self.saveButton.isEnabled = !(self.nameTextFiled.text?.isEmpty)!
        self.nameTextFiled.text = ""
    }
    
    func tapAction() {
        if self.displayNameTextField.isEditing { self.displayNameTextField.resignFirstResponder() }
        if self.nameTextFiled.isEditing { self.nameTextFiled.resignFirstResponder() }
    }
}


//MARK: Navigation
extension ChannelNameAndHandleTableViewController: Navigation {
    func returnToChannelSettings() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension ChannelNameAndHandleTableViewController: Request {
    func update() {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: Constants.ErrorMessages.message[0]); return }
        
        let name = self.nameTextFiled.text
        let displayName = self.displayNameTextField.text
        self.saveButton.isEnabled = false
        let channelId = self.channel.identifier
        
        Api.sharedInstance.update(newDisplayName: displayName!, newName: name!, channel: self.channel!, completion: { (error) in
            guard (error == nil) else { self.handleErrorWith(message: "Incorrect handle".localized); return }
            
            let realm = RealmUtils.realmForCurrentThread()
            let channel = realm.object(ofType: Channel.self, forPrimaryKey: channelId)
            try! realm.write {
                channel?.name = name
                channel?.displayName = displayName
            }
            
            let typeName = (self.channel.privateType! == "P") ? "Group" : "Channel"
            self.handleSuccesWith(message: typeName + " was updated")
        })
    }
}


//MARK:UITextFieldDelegate
extension ChannelNameAndHandleTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        
        if textField == self.nameTextFiled { self.clearNameButton.isHidden = newLength == 0 }
        if textField == self.displayNameTextField { self.clearDisplayNameButton.isHidden = newLength == 0 }
        self.saveButton.isEnabled = true
        
        return newLength <= limitLength
    }
}
