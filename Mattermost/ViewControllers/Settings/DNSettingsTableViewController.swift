//
//  DNSettingsTableViewController.swift
//  Mattermost
//
//  Created by Екатерина on 25.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class DNSettingsTableViewController: UITableViewController {

//MARK: Properties
    fileprivate var saveButton: UIBarButtonItem!
    
    fileprivate var notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
    fileprivate let user = DataManager.sharedInstance.currentUser
    
    var selectedSendOption: Int = 0
    var selectedSoundOption: Int = 0
    var selectedDurationOption: Int = 0
    
    
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
extension DNSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupForCurrentNotifyProps()
    }
    
    func setupNavigationBar() {
        self.title = "Mobile push notifications"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.saveButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
    
    func setupForCurrentNotifyProps() {
     //   self.selectedSendOption = Constants.NotifyProps.MobilePush.Send.index { return $0.state == (self.notifyProps?.push)! }!
     //   self.selectedTriggerOption = Constants.NotifyProps.MobilePush.Trigger.index { return $0.state == (self.notifyProps?.pushStatus)! }!
    }
}


//MARK: Action
extension DNSettingsTableViewController: Action {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        updateSettings()
    }
}


//MARK: Navigation
extension DNSettingsTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension DNSettingsTableViewController: Request {
    func updateSettings() {
    /*    try! RealmUtils.realmForCurrentThread().write {
            self.notifyProps?.push = Constants.NotifyProps.MobilePush.Send[self.selectedSendOption].state
            self.notifyProps?.pushStatus = Constants.NotifyProps.MobilePush.Trigger[self.selectedTriggerOption].state
        }
        
        Api.sharedInstance.updateNotifyProps(self.notifyProps!) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            self.saveButton.isEnabled = false
            let message = "User notification properties were successfully updated"
            AlertManager.sharedManager.showSuccesWithMessage(message: message, viewController: self)
        }*/
    }
}


//MARK: UITableViewDataSource
extension DNSettingsTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
        case 0:
            cell.accessoryType = (self.selectedSendOption == indexPath.row) ? .checkmark : .none
        case 1:
            cell.accessoryType = (self.selectedSoundOption == indexPath.row) ? .checkmark : .none
        case 2:
            cell.accessoryType = (self.selectedDurationOption == indexPath.row) ? .checkmark : .none
        default:
            break
        }

        return cell
    }
}


//MARK: UITableViewDelegate
extension DNSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedRow = 0
        switch indexPath.section {
        case 0:
           selectedRow = self.selectedSendOption
        case 1:
            selectedRow = self.selectedSoundOption
        case 2:
            selectedRow = self.selectedDurationOption
        default:
            break
        }
        guard indexPath.row != selectedRow else { return }
        
        self.saveButton?.isEnabled = true
        tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section))?.accessoryType = .none
        switch indexPath.section {
        case 0:
            self.selectedSendOption = indexPath.row
        case 1:
            self.selectedSoundOption = indexPath.row
        case 2:
            self.selectedDurationOption = indexPath.row
        default:
            break
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}
