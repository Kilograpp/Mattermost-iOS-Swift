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
class ChannelSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var channel: Channel!
    var selectedInfoType: InfoType!
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 2){
            return String(channel.members.count)+" members"
        }
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //CODEREVIEW: А зачем такой свитч. Его можно оформить аккуратнее
        switch (section){
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return (channel.members.count <= 5) ? (channel.members.count+1) : 7
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    //В отдельный блок и добаить билдер
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "headerChannelSettingsCell") as! HeaderChannelSettingsCell
            (cell as! HeaderChannelSettingsCell).channelName.text = channel.displayName!
            (cell as! HeaderChannelSettingsCell).channelFirstSymbol.text = String(channel.displayName![0])
        case 1:
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "informationChannelSettingsCell") as! InformationChannelSettingsCell
            switch (indexPath.row){
            case 0:
                cell0.infoName.text = "Header".localized
                cell0.infoDetail.text = channel.header
            case 1:
                cell0.infoName.text = "Purpose".localized
                cell0.infoDetail.text = channel.purpose!
            case 2:
                //FIXME: WRONG URL!!! (API URL, NEED CHANNEL URL)
                cell0.infoName.text = "URL".localized
                cell0.infoDetail.text = channel.buildURL()
                cell0.accessoryView = UIView()
                cell0.isCopyEnabled = true
            case 3:
                cell0.infoName.text = "ID".localized
                cell0.infoDetail.text = channel.identifier!
                cell0.accessoryView = UIView()
                cell0.isCopyEnabled = true
            default:
                break
            }
            cell = cell0
        case 2:
            let membersRowCount = (channel.members.count < 5) ? channel.members.count : 5
            if (indexPath.row==0){
                cell = tableView.dequeueReusableCell(withIdentifier: "addMembersChannelSettingsCell") as! AddMembersChannelSettingsCell
            } else if (indexPath.row == membersRowCount + 1) {
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
                cell1.cellText.text = "See all members"
                cell = cell1
            } else {
                let cell3 = tableView.dequeueReusableCell(withIdentifier: "memberChannelSettingsCell") as! MemberChannelSettingsCell
                cell3.configureWithUser(user: channel.members[indexPath.row-1])
                if (indexPath.row == membersRowCount){
                    cell3.separatorInset = UIEdgeInsets.zero
                    cell = cell3
                    break
                }
                cell3.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
                cell = cell3
            }
        case 3:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "labelChannelSettingsCell") as! LabelChannelSettingsCell
            let action = (channel.members.count > 1) ? "Leave" : "Delete"
            let type = (channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group" : "Channel"
            cell2.cellText.text = action + " " + type
            cell2.cellText.textColor = UIColor.red
            
            cell = cell2
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section){
        case 0:
            return 91
        case 1:
            return 50
        case 2:
            return 50
        case 3:
            return 56
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section){
        case 0:
            return 1.0
        case 1:
            return 30
        case 2:
            return 60
        case 3:
            return 30
        default:
            return 0
        }
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
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navbar_back_icon")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navbar_back_icon")
        
        if segue.identifier == "showMembersAdditing"{
            let addMembersViewController = segue.destination as! AddMembersViewController
            addMembersViewController.channel = self.channel
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let membersRowCount = (channel.members.count < 5) ? channel.members.count : 5
        
        guard self.lastSelectedIndexPath == nil else { return }
        self.lastSelectedIndexPath = indexPath
        
        if (indexPath==IndexPath(row: 0, section: 2)) {
            self.lastSelectedIndexPath = nil
            self.performSegue(withIdentifier: "showMembersAdditing", sender: nil)
        }
        if (indexPath.section==2 && indexPath.row >= 1 && indexPath.row <= membersRowCount){
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
            self.lastSelectedIndexPath = nil
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
            self.lastSelectedIndexPath = nil
            self.performSegue(withIdentifier: "showChannelInfo", sender: nil)
        }
        if (indexPath==IndexPath(row: 0, section: 3)){
            if self.channel.members.count == 1 {
                deleteChannel()
                return
            }
            
            Api.sharedInstance.leaveChannel(channel, completion: { (error) in
                guard (error == nil) else { self.lastSelectedIndexPath = nil; return }
                let channelType = (self.channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "group" : "channel"
                self.dismiss(animated: true, completion: {_ in
                    Api.sharedInstance.loadChannels(with: { (error) in
                        guard (error == nil) else { return }
                        AlertManager.sharedManager.showSuccesWithMessage(message: "You left ".localized + self.channel.displayName! + " " + channelType)
                    })
                })
            })
        }
        if (indexPath==IndexPath(row: 0, section: 0)){
            self.lastSelectedIndexPath = nil
            self.performSegue(withIdentifier: "showNameAndHandle", sender: nil)
        }
        
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
            let  message = channelType + self.channel.name! + " was deleted"
            AlertManager.sharedManager.showSuccesWithMessage(message: message)
        }
    }
}
