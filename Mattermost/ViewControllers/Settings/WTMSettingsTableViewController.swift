//
//  WTMSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class WTMSettingsTableViewController: UITableViewController {
    
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


fileprivate protocol LifeCycle {
    func viewDidLoad()
    func didReceiveMemoryWarning()
}

fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action {
    func backAction()
    func saveAction()
}

fileprivate protocol Navigation {
    func returtToNSettings()
}

fileprivate protocol Request {

}


//MARK: Setup
extension WTMSettingsTableViewController: Setup {
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
}
    

//MARK: Action
extension WTMSettingsTableViewController: Action {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        update()
    }
}


//MARK: Navigation
extension WTMSettingsTableViewController: Navigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension WTMSettingsTableViewController: Request {
    func update() {
        let notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
        print(notifyProps)
        Api.sharedInstance.updateNotifyProps(notifyProps!) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            let message = "User notification properties were successfully updated"
            AlertManager.sharedManager.showSuccesWithMessage(message: message, viewController: self)
        }
    }
}


//MARK: UITableViewDataSource
extension WTMSettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 4 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)        
        if indexPath.section == 0 {
            configure(cell: (cell as! CheckSettingsTableViewCell), indexPath: indexPath)
        }
        else {
            configure(cell: cell as! TextSettingsTableViewCell)
        }
        
        return cell
    }
    
    func configure(cell:CheckSettingsTableViewCell, indexPath: IndexPath) {
        let user = DataManager.sharedInstance.currentUser
        let notifyProps = user?.notificationProperies()
        
        let text = cell.descriptionLabel?.text
        switch indexPath.row {
        case 0:
            cell.descriptionLabel?.text = text! + "\"" + (user?.firstName)! + "\""
            cell.checkBoxButton?.isSelected = (notifyProps?.isSensitiveFirstName())!
        case 1:
            cell.descriptionLabel?.text = text! + "\"" + (user?.username)! + "\""
            cell.checkBoxButton?.isSelected = (notifyProps?.isNonCaseSensitiveUsername())!
        case 2:
            cell.descriptionLabel?.text = text! + "@\"" + (user?.username)! + "\""
            cell.checkBoxButton?.isSelected = (notifyProps?.isUsernameMentioned())!
        case 3:
            cell.checkBoxButton?.isSelected = (notifyProps?.isChannelWide())!
        default:
            break
        }
    }
    
    func configure(cell: TextSettingsTableViewCell) {
        let user = DataManager.sharedInstance.currentUser
        let notifyProps = user?.notificationProperies()
        
        cell.wordsTextView?.text = notifyProps?.otherNonCaseSensitive()
        cell.placeholderLabel?.isHidden = ((cell.wordsTextView?.text.characters.count)! > 0)
    }
}


//MARK: UITableViewDelegate
extension WTMSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        let cell = tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell
        cell.checkBoxButton?.isSelected = !(cell.checkBoxButton?.isSelected)!
    }
}


//MARK: UITextViewDelegate
extension WTMSettingsTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TextSettingsTableViewCell
        
        cell.placeholderLabel?.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath) as! TextSettingsTableViewCell
        
        cell.placeholderLabel?.isHidden = (textView.text.characters.count == 0)
    }
}
