//
//  NSettingsTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 26.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class NSettingsTableViewController: UITableViewController {

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
}

fileprivate protocol Action {
    func backAction()
}

fileprivate protocol Navigation {
    func returnToChat()
    func proceedToMPNSettings()
    func proceedToWTMSettings()
}

fileprivate protocol Request {
    func update()
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
        update()
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


//MARK: Request
extension NSettingsTableViewController {
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
extension NSettingsTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! CommonSettingsTableViewCell
        let user = DataManager.sharedInstance.currentUser
        let notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
        
        switch indexPath.section {
        case 2:
            let sendKey = notifyProps?.push
            let triggerKey = notifyProps?.pushStatus
            let send = Constants.NotifyProps.MobilePush.Send[sendKey!]
            let trigger = Constants.NotifyProps.MobilePush.Trigger[triggerKey!]
            cell.descriptionLabel?.text = send! + " when " + trigger!
        case 3:
            var words = (notifyProps?.firstName)! == "true" ? ("\"" + (user?.firstName)! + "\"") : ""
            let menion = (notifyProps?.mentionKeys)!.replacingOccurrences(of: ",", with: ", ")
            words += (words.characters.count > 0) ? " " : ""
            words += menion
            words += (words.characters.count > 0) ? " ," : ""
            words += (notifyProps?.channel) == "true" ? Constants.NotifyProps.Words.ChannelWide : ""
            cell.descriptionLabel?.text = (words.characters.count > 0) ? words : Constants.NotifyProps.Words.None
        default:
            break
        }
        
        return cell
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
