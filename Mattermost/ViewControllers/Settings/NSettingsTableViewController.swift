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


//MARK: UITableViewDataSource
extension NSettingsTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! CommonSettingsTableViewCell
        
        switch indexPath.section {
        case 2:
            let sendIndex = Constants.NotifyProps.MobilePush.Send.index { return $0.state == (self.notifyProps?.push)! }!
            let triggerIndex = Constants.NotifyProps.MobilePush.Trigger.index { return $0.state == (self.notifyProps?.pushStatus)! }!
            let send = Constants.NotifyProps.MobilePush.Send[sendIndex].description
            let trigger = Constants.NotifyProps.MobilePush.Trigger[triggerIndex].description
            cell.descriptionLabel?.text = send + " when " + trigger
            break
        case 3:
            var words = (notifyProps?.isSensitiveFirstName())! ? ("\"" + (user?.firstName)! + "\"") : ""
            if (notifyProps?.isNonCaseSensitiveUsername())! {
                words += (words.characters.count > 0) ? ", " : ""
                words += "\"" + (self.user?.username)! + "\""
            }
            if (notifyProps?.isUsernameMentioned())! {
                words += (words.characters.count > 0) ? ", " : ""
                words += "\"@" + (self.user?.username)! + "\""
            }
            if (notifyProps?.isChannelWide())! {
                words += (words.characters.count > 0) ? ", " : ""
                words += Constants.NotifyProps.Words.ChannelWide
            }
            let otherWords = notifyProps?.otherNonCaseSensitive()
            if ((otherWords?.characters.count)! > 0) {
                words += (words.characters.count > 0) ? ", " : ""
                words += otherWords!
            }
            
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
