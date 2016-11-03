//
//  NSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class NSettingsTableViewController: UITableViewController {

}


private protocol LifeCycle {
    func viewDidLoad()
}

private protocol Setup {
    func initialSetup()
    func setupNavigationBar()
}

private protocol Action {
    func backAction()
}

private protocol Navigation {
    func returnToChat()
    func proceedToMPNSettings()
    func proceedToWTMSettings()
}


//MARK: LifeCycle

extension NSettingsTableViewController: LifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
        let notifyProps = DataManager.sharedInstance.currentUser
        print(notifyProps)
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


//MARK: Setup

extension NSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.title = "Notification"
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
        self.navigationItem.rightBarButtonItem = saveButton
    }
}


//MARK: Action

extension NSettingsTableViewController: Action {
    func backAction() {
        returnToChat()
    }
    
    func saveAction() {
        
    }
}


//MARK: Navigation

extension NSettingsTableViewController: Navigation {
    func returnToChat() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToMPNSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let mPNSettrings = storyboard.instantiateViewController(withIdentifier: "MPNSettingsTableViewController")
        self.navigationController?.pushViewController(mPNSettrings, animated: true)
    }
    
    func proceedToWTMSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let wTMSettings = storyboard.instantiateViewController(withIdentifier: "WTMSettingsTableViewController")
        self.navigationController?.pushViewController(wTMSettings, animated: true)
    }
}


//MARK: UITableViewDelegate

extension NSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("")
        case 1:
            print("")
        case 2:
            proceedToMPNSettings()
        case 3:
            proceedToWTMSettings()
        case 4:
            print("")
        default:
            break
        }
    }
}
