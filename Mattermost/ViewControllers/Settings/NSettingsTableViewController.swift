//
//  NSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class NSettingsTableViewController: UITableViewController {
    
//MARK: Properties
    fileprivate lazy var builder: NSettingsCellBuilder = NSettingsCellBuilder(tableView: self.tableView)
    fileprivate var notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
    fileprivate let user = DataManager.sharedInstance.currentUser

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.menuContainerViewController.panMode = .init(0)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
}

fileprivate protocol Action {
    func backAction()
}

fileprivate protocol Navigation {
    func returnToChat()
    func proceedToDNSettings()
    func proccedToENSettings()
    func proceedToMPNSettings()
    func proceedToWTMSettings()
    func proceedToRNSettings()
}

fileprivate protocol Request {
    func update()
}


//MARK: Setup
extension NSettingsTableViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
//        setupSwipeRight()
    }
    
    func setupNavigationBar() {
        self.title = "Notification"
    }
    
    func setupSwipeRight() {
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(backAction))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
}


//MARK: Action
extension NSettingsTableViewController: Action {
    func backAction() {
        returnToChat()
    }
}


//MARK: Navigation
extension NSettingsTableViewController: Navigation {
    func returnToChat() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToDNSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let dNSettrings = storyboard.instantiateViewController(withIdentifier: "DNSettingsTableViewController")
        self.navigationController?.pushViewController(dNSettrings, animated: true)
    }
    
    func proccedToENSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let eNSettrings = storyboard.instantiateViewController(withIdentifier: "ENSettingsTableViewController")
        self.navigationController?.pushViewController(eNSettrings, animated: true)
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
    
    func proceedToRNSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let rNSettings = storyboard.instantiateViewController(withIdentifier: "RNSettingsTableViewController")
        self.navigationController?.pushViewController(rNSettings, animated: true)
    }
}


//MARK: UITableViewDataSource
extension NSettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.builder.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.builder.numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(notifyProps: self.notifyProps!, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension NSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            proceedToDNSettings()
        case 1:
            proccedToENSettings()
        case 2:
            proceedToMPNSettings()
        case 3:
            proceedToWTMSettings()
        case 4:
            proceedToRNSettings()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.builder.title(section: section)
    }
}
