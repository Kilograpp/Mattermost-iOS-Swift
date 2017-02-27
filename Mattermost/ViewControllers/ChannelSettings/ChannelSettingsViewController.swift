//
//  ChannelSettingsViewController.swift
//  Mattermost
//
//  Created by Владислав on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import WebImage
import RealmSwift

private protocol Configuration: class {
    func configureWith(channelId: String)
}

class ChannelSettingsViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var builder: ChannelSettingsCellBuilder = ChannelSettingsCellBuilder(tableView: self.tableView)
    
    var channel: Channel!
    var selectedInfoType: InfoType!
    var usersAreNotInChannel = Array<User>()
    fileprivate var statusesTimer: Timer?
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        replaceStatusBar()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIStatusBar.shared().reset()
    }
}


//MARK: Configuration
extension ChannelSettingsViewController: Configuration {
    func configureWith(channelId: String) {
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func prepareChannelData()
    func setupChannelObservers()
}

fileprivate protocol Action: class {
    func backAction()
}

fileprivate protocol Navigation: class {
    func returnToChat()
    func proceedToChannelNameAndHandler()
    func proceedToChannelHeaderAndDescriptionWith(infoIndex: Int)
    func proceedToAddMembers()
    func proceedToAllMembers()
}

fileprivate protocol Request: class {
    func createDirectChannelWith(user: User)
    func deleteChannel()
    func leaveChannel()
    func loadChannel()
    func loadUsersList()
}

fileprivate protocol StatusesTimer: class {
    func configureStartUpdating()
    func updateStatuses()
    func stopTimer()
}


//MARK: Setup
extension ChannelSettingsViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        loadChannel()
     //   setupChannelObservers()
    }
    
    func setupNavigationBar() {
        self.title = (channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group Info".localized : "Channel Info".localized
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backAction)), animated: true)
    }
    
    func prepareChannelData() {
        loadChannel()
    }
    
    func setupChannelObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopTimer),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.StatusesSocketNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadChannel),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification),
                                               object: nil)
    }
}


//MARK: Action
extension ChannelSettingsViewController: Action {
    func backAction() {
        returnToChat()
    }
}


//MARK: Navigation
extension ChannelSettingsViewController: Navigation {
    func returnToChat() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func proceedToChannelNameAndHandler() {
        let channelNameAndHandler = self.storyboard?.instantiateViewController(withIdentifier: "ChannelNameAndHandleTableViewController") as! ChannelNameAndHandleTableViewController
        channelNameAndHandler.configureWith(channelId: self.channel.identifier!)
        self.navigationController?.pushViewController(channelNameAndHandler, animated: true)
    }
    
    func proceedToChannelHeaderAndDescriptionWith(infoIndex: Int) {
        let channelHeaderAndDescription = self.storyboard?.instantiateViewController(withIdentifier: "ChannelHeaderAndDescriptionTableViewController") as! ChannelHeaderAndDescriptionTableViewController
        let infoType = infoIndex == 0 ? InfoType.header : InfoType.purpose
        channelHeaderAndDescription.configureWith(channelId: self.channel.identifier!, infoType: infoType)
        self.navigationController?.pushViewController(channelHeaderAndDescription, animated: true)
    }
    
    func proceedToAddMembers() {
        let addMembers = self.storyboard?.instantiateViewController(withIdentifier: "AddMembersViewController") as! AddMembersViewController
        addMembers.configureWith(channelId: self.channel.identifier!)
        self.navigationController?.pushViewController(addMembers, animated: true)
    }
    
    func proceedToAllMembers() {
        let allMembers = self.storyboard?.instantiateViewController(withIdentifier: "AllMembersViewController") as! AllMembersViewController
        allMembers.configureWith(channelId: self.channel.identifier!)
        self.navigationController?.pushViewController(allMembers, animated: true)
    }
}


//MARK: Request
extension ChannelSettingsViewController: Request {
    func createDirectChannelWith(user: User) {
        Api.sharedInstance.createDirectChannelWith(user, completion: {_ in
            ChannelObserver.sharedObserver.selectedChannel = user.directChannel()
            print("Proceed to dialog")
        })
    }
    
    func deleteChannel() {
        guard Api.sharedInstance.isNetworkReachable() else {
            AlertManager.sharedManager.showErrorWithMessage(message: "No Internet connectivity detected")
            return
        }
        Api.sharedInstance.delete(channel: self.channel) { (error) in
            let deletedCannel = self.channel
            
            let leftMenu = self.presentingViewController?.menuContainerViewController.leftMenuViewController as! LeftMenuViewController
            leftMenu.configureInitialSelectedChannel()
            self.dismiss(animated: true, completion: {
                let realm = RealmUtils.realmForCurrentThread()
                try! realm.write { realm.delete(deletedCannel!) }
                leftMenu.reloadChannels()
            })
            let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group " : "Channel "
            self.handleSuccesWith(message: channelType + self.channel.displayName! + " was deleted")
        }
    }
    
    func leaveChannel() {
        guard Api.sharedInstance.isNetworkReachable() else {
            AlertManager.sharedManager.showErrorWithMessage(message: "No Internet connectivity detected")
            return
        }
        Api.sharedInstance.leaveChannel(channel, completion: { (error) in
            let leavedCannel = self.channel
            let leftMenu = self.presentingViewController?.menuContainerViewController.leftMenuViewController as! LeftMenuViewController
            leftMenu.configureInitialSelectedChannel()
            self.dismiss(animated: true, completion: {
                let realm = RealmUtils.realmForCurrentThread()
                try! realm.write { realm.delete(leavedCannel!) }
                leftMenu.reloadChannels()
            })
            let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
            self.handleSuccesWith(message: "You left ".localized + self.channel.displayName! + " " + channelType)
        })
    }
    
    func loadChannel() {
        self.showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
        Api.sharedInstance.getChannel(channel: self.channel, completion: { (error) in
            guard error == nil else {
                self.handleErrorWith(message: (error?.message)!)
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.loadUsersList()
        })
    }
    
    func loadUsersList() {
        Api.sharedInstance.loadUsersListFrom(channel: self.channel, completion: { (error) in
            guard error == nil else {
                let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
                self.handleErrorWith(message: "You left this \(channelType)".localized)
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.channel = try! Realm().objects(Channel.self).filter("identifier = %@", self.channel.identifier!).first!
            self.tableView.reloadData()
            self.hideLoaderView()
        })
    }
}


//MARK: Timer
extension ChannelSettingsViewController: StatusesTimer {
    func configureStartUpdating() {
         _ = UserStatusObserver.sharedObserver
         self.statusesTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateStatuses), userInfo: nil, repeats: true)
    }
    
    func updateStatuses() {
        SocketManager.sharedInstance.publishBackendNotificationFetchStatuses()
    }
    
    func stopTimer() {
        if (self.statusesTimer != nil) {
            self.statusesTimer?.invalidate()
            self.statusesTimer = nil
        }
    }
}


//MARK: UITableViewDataSource
extension ChannelSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.builder.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.builder.numberOfRows(channel: self.channel, section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(channel: self.channel, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension ChannelSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeightFor(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.builder.sectionHeaderHeightFor(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.builder.titleForHeader(channel: self.channel, section: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            proceedToChannelNameAndHandler()
        case 1:
            guard indexPath.row < 2 else { break }
            proceedToChannelHeaderAndDescriptionWith(infoIndex: indexPath.row)
        case 2:
            switch indexPath.row {
            case 0:
                proceedToAddMembers()
            case 6:
                proceedToAllMembers()
            default:
                break
            }
            break
        case 3:
            if self.channel.members.count > 1 {
                leaveChannel()
            } else {
                deleteChannel()
            }
        default:
            break
        }
    }
}
