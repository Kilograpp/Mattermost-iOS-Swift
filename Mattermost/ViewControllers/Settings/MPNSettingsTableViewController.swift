//
//  MPNSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class MPNSettingsTableViewController: UITableViewController {
    
//MARK: Properties
    
    
}


private protocol MPNSettingsTableViewControllerLifeCycle {
    func viewDidLoad()
}


private protocol MPNSettingsTableViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupForCurrentSettings()
}

private protocol MPNSettingsTableViewControllerAction {
    func backAction()
    func saveAction()
}

private protocol MPNSettingsTableViewControllerNavigation {
    func returtToNSettings()
}

private protocol MPNSettingsTableViewControllerRequest {
    func saveSettings()
}


//MARK: MPNSettingsTableViewControllerLifeCycle

extension MPNSettingsTableViewController: MPNSettingsTableViewControllerLifeCycle {
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


//MARK: MPNSettingsTableViewControllerSetup

extension MPNSettingsTableViewController: MPNSettingsTableViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.title = "Mobile push notifications"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func setupForCurrentSettings() {
        
    }
}


//MARK: MPNSettingsTableViewControllerAction

extension MPNSettingsTableViewController: MPNSettingsTableViewControllerAction {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        saveSettings()
    }
}


//MARK: MPNSettingsTableViewControllerNavigation

extension MPNSettingsTableViewController: MPNSettingsTableViewControllerNavigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: MPNSettingsTableViewControllerRequest

extension MPNSettingsTableViewController: MPNSettingsTableViewControllerRequest {
    func saveSettings() {
        
    }
}


//MARK: UITableViewDelegate

extension MPNSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.sharedInstance.currentUser?.notificationProperies().hasUpdated = true
        let number = tableView.numberOfRows(inSection: indexPath.section)
        for row in 0..<number {
            let cell = tableView.cellForRow(at: IndexPath.init(row: row, section: indexPath.section))
            cell?.accessoryType = (row == indexPath.row) ? .checkmark : .none
        }
    }
}
