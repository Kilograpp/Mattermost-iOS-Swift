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

//CODEREVIEW: Нужно разнести методы по разным блокам, добавить билдер для ячеек и переоформить методы настройки и тапая ячейки
//CODEREVIEW: В didSelect совсем что-то жесткое. Там запросы, до перехода к целевому контроллеру, что и позволяет до перехода тапнуть на ячейку еще раз
class ChannelSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var channel: Channel!
    var selectedInfoType: InfoType!
    var usersAreNotInChannel = Array<User>()
    let cellBuilder = ChanenlSettingsCellBuilder()
    var lastSelectedIndexPath: IndexPath? = nil
    
    //temp timer
    var statusesTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        setupChannelsObserver()
        setupNibs()
        self.loadData()
    }
    
    func setupNavigationBar() {
        if channel.privateType == "P"{
            self.title = "Group Info".localized
        } else  {
            self.title = "Channel Info".localized
        }
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backAction)), animated: true)
    }
    
    //Имеет смысл передавать идентификатор, а не сам объект
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMembersAdditing"{
            let addMembersViewController = segue.destination as! AddMembersViewController
            addMembersViewController.channel = self.channel
            addMembersViewController.users = self.usersAreNotInChannel
            self.hideLoaderView()
        }
        
        if segue.identifier == "showAllMembers"{
            let allMembersViewController = segue.destination as! AllMembersViewController
            allMembersViewController.channel = self.channel
        }
        if segue.identifier == "showChannelInfo"{
            let channelHeaderAndDescriptionViewController = segue.destination as! ChannelHeaderAndDescriptionViewController
            channelHeaderAndDescriptionViewController.channel = self.channel
            channelHeaderAndDescriptionViewController.type = selectedInfoType
        }
        if segue.identifier == "showNameAndHandle"{
            let channelNameAndHandleViewController = segue.destination as! ChannelNameAndHandleViewController
            channelNameAndHandleViewController.channel = self.channel
        }
    }
    
    func reloadChannel() {
        self.tableView.reloadData()
    }
    
    func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
    }
    
    //refactor later -> ObserverUtils
    func setupChannelsObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopTimer),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.StatusesSocketNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChannel),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification),
                                               object: nil)
    }
    
    fileprivate func setupNibs(){
        let nib1 = UINib(nibName: "HeaderChannelSettingsCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "headerChannelSettingsCell")
        let nib2 = UINib(nibName: "InformationChannelSettingsCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "informationChannelSettingsCell")
        let nib3 = UINib(nibName: "MemberChannelSettingsCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "memberChannelSettingsCell")
        let nib4 = UINib(nibName: "AddMembersChannelSettingsCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "addMembersChannelSettingsCell")
        let nib5 = UINib(nibName: "LabelChannelSettingsCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "labelChannelSettingsCell")
    }
    
    //TEMP TODO:  update statuses
    fileprivate func configureStartUpdating() {
        //Костыль (для инициализации UserStatusObserver)
        UserStatusObserver.sharedObserver
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


fileprivate protocol Request: class {
    func deleteChannel()
    func leaveChannel()
}

extension ChannelSettingsViewController: Request {
    func deleteChannel() {
        Api.sharedInstance.delete(channel: self.channel) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            
            let deletedCannel = self.channel
            let leftMenu = self.presentingViewController?.menuContainerViewController.leftMenuViewController as! LeftMenuViewController
            leftMenu.configureInitialSelectedChannel()
            self.dismiss(animated: true, completion: {
                let realm = RealmUtils.realmForCurrentThread()
                try! realm.write {
                    realm.delete(deletedCannel!)
                }
                leftMenu.reloadChannels()
            })
            let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group " : "Channel "
            let  message = channelType + self.channel.displayName! + " was deleted"
            AlertManager.sharedManager.showSuccesWithMessage(message: message)
        }
    }
    
    func leaveChannel() {
        Api.sharedInstance.leaveChannel(channel, completion: { (error) in
            guard (error == nil) else { self.lastSelectedIndexPath = nil; return }
            let leavedCannel = self.channel
            let leftMenu = self.presentingViewController?.menuContainerViewController.leftMenuViewController as! LeftMenuViewController
            leftMenu.configureInitialSelectedChannel()
            self.dismiss(animated: true, completion: {
                let realm = RealmUtils.realmForCurrentThread()
                try! realm.write {
                    realm.delete(leavedCannel!)
                }
                leftMenu.reloadChannels()
            })
            let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
            AlertManager.sharedManager.showSuccesWithMessage(message: "You left ".localized + self.channel.displayName! + " " + channelType)
        })
    }
}

extension ChannelSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cellBuilder.titleForHeader(channel: channel, section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellBuilder.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellBuilder.numberOfRows(channel: channel, section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerChannelSettingsCell") as! HeaderChannelSettingsCell
            return cellBuilder.buildHeaderCell(cell: headerCell, channel: channel)
        case 1:
            let informationCell = tableView.dequeueReusableCell(withIdentifier: "informationChannelSettingsCell") as! InformationChannelSettingsCell
            return cellBuilder.buildInformationCell(cell: informationCell, channel: channel, indexPath: indexPath)
        case 2:
            let membersRowCount = (channel.members.count < 5) ? channel.members.count : 5
            if (indexPath.row==0){
                return tableView.dequeueReusableCell(withIdentifier: "addMembersChannelSettingsCell") as! AddMembersChannelSettingsCell
                
            } else if (indexPath.row == membersRowCount + 1) {
                let allMembersCell = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
                return cellBuilder.buildAllMembersCell(cell: allMembersCell)
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberChannelSettingsCell") as! MemberChannelSettingsCell
                cell.configureWithUser(user: channel.members[indexPath.row-1])
                if (indexPath.row == membersRowCount){
                    cell.separatorInset = UIEdgeInsets.zero
                    return cell
                    break
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
                return cell
            }
        case 3:
            let leaveDeleteChannelCell = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
            return cellBuilder.buildLeaveDeleteChannelCell(cell: leaveDeleteChannelCell, channel: channel)
        default: break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellBuilder.heightForRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellBuilder.heightForSectionHeader(section: section)
    }
}

extension ChannelSettingsViewController: UITableViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        replaceStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIStatusBar.shared().reset()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let membersRowCount = (channel.members.count < 5) ? channel.members.count : 5
        
        guard self.lastSelectedIndexPath == nil else { return }
        
        if (indexPath==IndexPath(row: 0, section: 2)) {
            self.showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
            Api.sharedInstance.loadUsersAreNotIn(channel: self.channel, completion: { (error, users) in
                guard (error==nil) else {
                    AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                    self.hideLoaderView()
                    return
                }
                self.usersAreNotInChannel = users!
                self.performSegue(withIdentifier: "showMembersAdditing", sender: nil)
            })
        }
        if (indexPath.section==2 && indexPath.row >= 1 && indexPath.row <= membersRowCount){
            self.lastSelectedIndexPath = indexPath
            
            let member = channel.members[indexPath.row-1]
            
            if member.identifier == Preferences.sharedInstance.currentUserId!{
                self.lastSelectedIndexPath = nil
                return
            }
            
            if member.directChannel() == nil{
                Api.sharedInstance.createDirectChannelWith(member, completion: {_ in
                    ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
                    self.lastSelectedIndexPath = nil
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
                self.lastSelectedIndexPath = nil
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        if (indexPath==IndexPath(row: membersRowCount+1, section: 2)){
            self.performSegue(withIdentifier: "showAllMembers", sender: nil)
        }
        if (indexPath==IndexPath(row: 0, section: 1) ||
            indexPath==IndexPath(row: 1, section: 1)){
            
            switch indexPath {
            case IndexPath(row: 0, section: 1):
                selectedInfoType = InfoType.header
            case IndexPath(row: 1, section: 1):
                selectedInfoType = InfoType.purpose
            default:
                break
            }
            self.performSegue(withIdentifier: "showChannelInfo", sender: nil)
        }
        if (indexPath==IndexPath(row: 0, section: 3)){
            if self.channel.members.count == 1 {
                deleteChannel()
                return
            }
            self.lastSelectedIndexPath = indexPath
            leaveChannel()
        }
        if (indexPath==IndexPath(row: 0, section: 0)){
            self.lastSelectedIndexPath = nil
            self.performSegue(withIdentifier: "showNameAndHandle", sender: nil)
        }
        
    }
    
    func loadData() {
        self.showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
        Api.sharedInstance.getChannel(channel: self.channel, completion: { (error) in
            guard error == nil else {
                self.handleErrorWith(message: (error?.message)!)
                self.dismiss(animated: true, completion: nil)
                return
            }
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
        })
    }

}
