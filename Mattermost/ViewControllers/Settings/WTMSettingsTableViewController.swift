//
//  WTMSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class WTMSettingsTableViewController: UITableViewController {

}

private protocol WTMSettingsTableViewControllerLifeCycle {
    func viewDidLoad()
    func didReceiveMemoryWarning()
}

private protocol WTMSettingsTableViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupForCurrentSettings()
}

private protocol WTMSettingsTableViewControllerAction {
    func backAction()
    func saveAction()
}

private protocol WTMSettingsTableViewControllerNavigation {
    func returtToNSettings()
}

private protocol WTMSettingsTableViewControllerRequest {

}


//MARK: WTMSettingsTableViewControllerLifeCycle

extension WTMSettingsTableViewController: WTMSettingsTableViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
    

//MARK: WTMSettingsTableViewControllerSetup

extension WTMSettingsTableViewController: WTMSettingsTableViewControllerSetup {
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
    

//MARK: WTMSettingsTableViewControllerAction

extension WTMSettingsTableViewController: WTMSettingsTableViewControllerAction {
    func backAction() {
        returtToNSettings()
    }
    
    func saveAction() {
        saveSettings()
    }
}


//MARK: WTMSettingsTableViewControllerNavigation

extension WTMSettingsTableViewController: WTMSettingsTableViewControllerNavigation {
    func returtToNSettings() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: WTMSettingsTableViewControllerRequest

extension WTMSettingsTableViewController: WTMSettingsTableViewControllerRequest {
    func saveSettings() {
        
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
        if (indexPath.section == 0) {
            (cell as! CheckSettingsTableViewCell).checkBoxHandler = {
                print("some check")
            }
        }
        else {
            print("texttt")
        }
        return cell
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