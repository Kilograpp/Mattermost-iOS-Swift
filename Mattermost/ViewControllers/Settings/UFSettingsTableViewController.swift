//
//  UFSettingsTableViewController.swift
//  Mattermost
//
//  Created by Екатерина on 25.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Configuration: class {
    func configureWith(userFieldType: Int)
}

class UFSettingsTableViewController: UITableViewController {

//MARK: Property
    fileprivate var saveButton: UIBarButtonItem!
    fileprivate lazy var builder: UFSettingsCellBuilder = UFSettingsCellBuilder(tableView: self.tableView, userFieldType: self.userFieldType)
    fileprivate var userFieldType: Int!
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


//MARK: Configuration
extension UFSettingsTableViewController: Configuration {
    func configureWith(userFieldType: Int) {
        self.userFieldType = userFieldType
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action: class {
    func backAction()
    func saveAction()
}

fileprivate protocol Navigation: class {
    func returtToSettings()
}

fileprivate protocol Request: class {
    func updateFullName()
    func updateUserName()
    func updateNickName()
    func updateEmail()
    func updatePassword()
}


//MARK: Setup
extension UFSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.title = "Edit"
        
        self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
}


//MARK: Action
extension UFSettingsTableViewController: Action {
    func backAction() {
        returtToSettings()
    }
    
    func saveAction() {
        switch Int(self.userFieldType) {
        case Constants.UserFieldType.FullName:
            updateFullName()
        case Constants.UserFieldType.UserName:
            updateUserName()
        case Constants.UserFieldType.NickName:
            updateNickName()
        case Constants.UserFieldType.Email:
            updateEmail()
        case Constants.UserFieldType.Password:
            updatePassword()
        default:
            return
        }
    }
}


//MARK: Navigation
extension UFSettingsTableViewController: Navigation {
    func returtToSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Request
extension UFSettingsTableViewController: Request {
    internal func updateFullName() {
        let firstName = self.builder.infoFor(section: 0)
        let lastName = self.builder.infoFor(section: 1)
        
        Api.sharedInstance.update(firstName: firstName, lastName: lastName) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            self.tableView.reloadData()
            AlertManager.sharedManager.showSuccesWithMessage(message: "Display name was successfully updated")
            self.returtToSettings()
        }
    }
    
    func updateUserName() {
        let userName = self.builder.infoFor(section: 0)
        Api.sharedInstance.update(userName: userName) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadRightMenuNotification), object: nil)
            AlertManager.sharedManager.showSuccesWithMessage(message: "Username was successfully updated")
            self.returtToSettings()
        }
    }
    
    internal func updateNickName() {
        let nickName = self.builder.infoFor(section: 0)
        Api.sharedInstance.update(nickName: nickName) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            AlertManager.sharedManager.showSuccesWithMessage(message: "Nickname was successfully updated")
            self.returtToSettings()
        }
    }
    
    internal func updateEmail() {
        let email = self.builder.infoFor(section: 0)
        guard email.isValidEmail() else { handleErrorWith(message: "Email is invalid"); return }
        
        Api.sharedInstance.update(email: email) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            AlertManager.sharedManager.showSuccesWithMessage(message: "Email was successfully updated")
            self.returtToSettings()
        }
    }
    
    internal func updatePassword() {
        guard Api.sharedInstance.isNetworkReachable() else { self.handleErrorWith(message: "No Internet connectivity detected"); return }
        
        self.showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
        
        let oldPassword = self.builder.infoFor(section: 0)
        let newPassword = self.builder.infoFor(section: 1)
        let retryNewPassword = self.builder.infoFor(section: 2)
        guard newPassword == retryNewPassword else {
            AlertManager.sharedManager.showErrorWithMessage(message: "New password in fields isn't same.")
            self.hideLoaderView()
            return
        }
        
        Api.sharedInstance.update(currentPassword: oldPassword, newPassword: newPassword) { (error) in
            self.hideLoaderView()
            guard error == nil else {
                if error?.code == -1011 {
                    AlertManager.sharedManager.showErrorWithMessage(message: "Wrong old password")
                    return
                }
                //Костыль (message on rus)
                guard error?.message != "Ваш пароль должен содержать по крайней мере 5 символов." else {
                    AlertManager.sharedManager.showErrorWithMessage(message: "Password must contain 5 characters at least.")
                    return
                }
                
                guard error?.code != 403 else {
                    self.handleErrorWith(message: "The \"Current Password\" you entered is incorrect. Please check that Caps Lock is off and try again.");
                    return
                }
                
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            
            self.saveButton.isEnabled = false
            AlertManager.sharedManager.showSuccesWithMessage(message: "Password was successfully updated")
            self.returtToSettings()
        }
    }
}


//MARK: UITableViewDataSource
extension UFSettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.builder.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.builder.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension UFSettingsTableViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.builder.title(section: section)
    }
}


//MARK: UITextFieldDelegate
extension UFSettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.saveButton.isEnabled = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.saveButton.isEnabled = true
        return true
    }
}
