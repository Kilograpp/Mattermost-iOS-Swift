//
//  ENSettingsTableViewController.swift
//  Mattermost
//
//  Created by Екатерина on 29.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class ENSettingsTableViewController: UITableViewController {

//MARK: Properties
    fileprivate var saveButton: UIBarButtonItem!
    fileprivate var notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
    fileprivate let user = DataManager.sharedInstance.currentUser
    
    var selectedEmailOption: Int = 0
    
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


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupForCurrentNotifyProps()
}

fileprivate protocol Action {
    func backAction()
    func saveAction()
}

private protocol Navigation {
    func returtToNSettings()
}

fileprivate protocol Request {
    func updateSettings()
}


//MARK: Setup
extension ENSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupForCurrentNotifyProps()
    }
    
    func setupNavigationBar() {
        self.title = "Email notifications"
        
        
        self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupForCurrentNotifyProps() {
        self.selectedEmailOption = (self.notifyProps?.email == /*"true"*/Constants.CommonStrings.True) ? 0 : 1
    }
}


//MARK: Action
extension ENSettingsTableViewController: Action {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        updateSettings()
    }
}


//MARK: Navigation
extension ENSettingsTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension ENSettingsTableViewController: Request {
    func updateSettings() {
        try! RealmUtils.realmForCurrentThread().write {
            self.notifyProps?.email = (self.selectedEmailOption == 0) ? /*"true"*/Constants.CommonStrings.True : Constants.CommonStrings.False//"false"
        }
        
        Api.sharedInstance.updateNotifyProps(self.notifyProps!) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            self.saveButton.isEnabled = false
            let message = "User notification properties were successfully updated"
            AlertManager.sharedManager.showSuccesWithMessage(message: message)
        }
    }
}


//MARK: UITableViewDataSource
extension ENSettingsTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = (self.selectedEmailOption == indexPath.row) ? .checkmark : .none
        
        return cell
    }
}


//MARK: UITableViewDelegate
extension ENSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != self.selectedEmailOption else { return }
        
        self.saveButton?.isEnabled = true
        tableView.cellForRow(at: IndexPath(row: self.selectedEmailOption, section: indexPath.section))?.accessoryType = .none
        
        self.selectedEmailOption = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}
