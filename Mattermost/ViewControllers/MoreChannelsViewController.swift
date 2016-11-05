//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift



typealias ResultTuple = (object: RealmObject, checked: Bool)

final class MoreChannelsViewController: UIViewController {
    
//MARK: Property
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate var addDoneButton: UIBarButtonItem!
    fileprivate let emptySearchLabel = EmptyDialogueLabel()
    
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    fileprivate let showChatViewController = "showChatViewController"
    
    fileprivate var results: Array<ResultTuple>! = Array()
    fileprivate var filteredResults: Array<ResultTuple>! = Array()
    
    var isPrivateChannel: Bool = false
    var isSearchActive: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}


private protocol MoreChannelsViewControllerLifeCycle {
    func viewDidLoad()
}

private protocol MoreChannelsViewControllerSetup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
}

private protocol MoreChannelsViewControllerConfiguration : class {
    var isPrivateChannel : Bool {get set}
    func prepareResults()
}

private protocol MoreChannelsViewControllerAction {
    func backAction()
    func addDoneAction()
}

private protocol MoreChannelsViewControllerNavigation {
    func returnToChannel()
}

private protocol MoreChannelsViewControllerRequest {
    func loadChannels()
    func loadAllChannels()
    func joinTo(channel: Channel)
    func leave(channel: Channel)
    func createDirectChannelWith(result: ResultTuple)
    func updatePreferencesSave(result: ResultTuple)
}

//MARK: LifeCycle

extension MoreChannelsViewController: MoreChannelsViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        if self.isPrivateChannel {
            loadChannels()
        } else {
            loadAllChannels()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


//MARK: Setup

extension MoreChannelsViewController: MoreChannelsViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupEmptyDialogueLabel()
        
        self.menuContainerViewController.panMode = .init(0)
    }
    
    func setupNavigationBar() {
        self.title = self.isPrivateChannel ? "Add Users".localized : "More Channel".localized
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let addDoneTitle = self.isPrivateChannel ? "Done".localized : "Save".localized
        self.addDoneButton = UIBarButtonItem.init(title: addDoneTitle, style: .done, target: self, action: #selector(addDoneAction))
        self.addDoneButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = self.addDoneButton
    }
    
    func setupSearchBar() {
        self.searchBar.returnKeyType = .done
        self.searchBar.enablesReturnKeyAutomatically = false
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.register(ChannelsMoreTableViewCell.self, forCellReuseIdentifier: ChannelsMoreTableViewCell.reuseIdentifier, cacheSize: 10)
    }
    
    fileprivate func setupEmptyDialogueLabel() {
        self.emptySearchLabel.backgroundColor = self.tableView.backgroundColor
        let moreType = (self.isPrivateChannel) ? "direct chats" : "channels"
        self.emptySearchLabel.text = "No " + moreType + " found!"
        self.view.insertSubview(self.emptySearchLabel, aboveSubview: self.tableView)
    }
}


//MARK: Configuration

extension  MoreChannelsViewController: MoreChannelsViewControllerConfiguration  {
    func prepareResults() {
        if (self.isPrivateChannel) {
            prepareUserResults()
        } else {
            prepareChannelResults()
        }
    }
    
    func prepareChannelResults() {
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        for channel in channels {
            self.results?.append((channel, channel.currentUserInChannel))
        }
    }
    
    func prepareUserResults() {
        let sortName = UserAttributes.username.rawValue
        let predicate =  NSPredicate(format: "identifier != %@ AND identifier != %@", Constants.Realm.SystemUserIdentifier,
                                                                                      Preferences.sharedInstance.currentUserId!)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        for user in users {
            self.results?.append((user, user.isSelectedDirectChannel()))
        }
    }
    
    func saveResults() {
        if self.isPrivateChannel {
            saveUserResults()
        } else {
            saveChannelResults()
        }
    }
    
    func saveChannelResults() {
        for resultTuple in self.results {
            let channel = (resultTuple.object as! Channel)
            guard channel.currentUserInChannel != resultTuple.checked else { continue }
            
            if resultTuple.checked {
                joinTo(channel: channel)
            } else {
                leave(channel: channel)
            }
        }
        self.addDoneButton.isEnabled = false
    }
    
    func saveUserResults() {
        for resultTuple in self.results {
            if !(resultTuple.object as! User).hasChannel() {
                createDirectChannelWith(result: resultTuple)
            } else {
                updatePreferencesSave(result: resultTuple)
            }
        }
        self.addDoneButton.isEnabled = false
    }
}


//MARK: Action

extension MoreChannelsViewController: MoreChannelsViewControllerAction {
    func backAction() {
        self.returnToChannel()
    }
    
    func addDoneAction() {
        saveResults()
    }
}


//MARK: Navigation

extension MoreChannelsViewController: MoreChannelsViewControllerNavigation {
    func returnToChannel() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: MoreChannelsViewControllerRequest

extension MoreChannelsViewController: MoreChannelsViewControllerRequest {
    func loadChannels() {
        Api.sharedInstance.loadChannels { (error) in
            Api.sharedInstance.listUsersPreferencesWith("direct_channel_show", completion: { (error) in
                self.prepareResults()
                self.tableView.reloadData()
            })
        }
    }
    
    func loadAllChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
    
    func joinTo(channel: Channel) {
        Api.sharedInstance.joinChannel(channel) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            let message = "You have joined " + channel.displayName! + " channel"
            AlertManager.sharedManager.showSuccesWithMessage(message: message, viewController: self)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
        }
    }
    
    func leave(channel: Channel) {
        Api.sharedInstance.leaveChannel(channel) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            
            let message = "You have left " + channel.displayName! + " channel"
            AlertManager.sharedManager.showSuccesWithMessage(message: message, viewController: self)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
        }
    }
    
    func createDirectChannelWith(result: ResultTuple) {
        guard  result.checked != (result.object as! User).hasChannel() else { return }
        
        Api.sharedInstance.createDirectChannelWith((result.object as! User)) { (channel, error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            
            self.updatePreferencesSave(result: result)
        }
    }
    
    func updatePreferencesSave(result: ResultTuple) {
        let user = (result.object as! User)
        
        guard user.isSelectedDirectChannel() != result.checked else { return }
        
        let predicate =  NSPredicate(format: "displayName == %@", user.username!)
        let channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).first
        
        try! RealmUtils.realmForCurrentThread().write {
            channel?.currentUserInChannel = result.checked ? true : false
        }
        
        let preferences: Dictionary<String, String> = [ "user_id" : (DataManager.sharedInstance.currentUser?.identifier)!,
                                                        "category" : "direct_channel_show",
                                                        "name" : (result.object as! User).identifier,
                                                        "value" : result.checked ? "true" : "false"
        ]
        
        Api.sharedInstance.savePreferencesWith(preferences) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            self.addDoneButton.isEnabled = false
            let action = result.checked ? "added " : "deleted "
            let message = "Chat with " + user.displayName! + " was " + action + " from your left menu"
            AlertManager.sharedManager.showSuccesWithMessage(message: message, viewController: self)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
        }
    }
}


//MARK: UITableViewDataSource

extension MoreChannelsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var resultTuple = self.isSearchActive ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        let cell = self.builder.cellFor(resultTuple: resultTuple)
        (cell as! ChannelsMoreTableViewCell).checkBoxHandler = {
            self.addDoneButton.isEnabled = true
            resultTuple.checked = !resultTuple.checked
            if self.isSearchActive {
                self.filteredResults[indexPath.row] = resultTuple
                let realIndex = self.results.index(where: { return ($0.object == resultTuple.object) })
                self.results[realIndex!] = resultTuple
            } else {
                self.results[indexPath.row] = resultTuple
            }
        }

        return cell
    }
}


//MARK: UITableViewDelegate

extension MoreChannelsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
}


//MARK: UISearchBarDelegate

extension MoreChannelsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = ((self.searchBar.text?.characters.count)! > 0)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = ((self.searchBar.text?.characters.count)! > 0)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = nil
        self.searchBar.resignFirstResponder()
        self.isSearchActive = false
        self.tableView.reloadData()
        self.filteredResults = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //self.isSearchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearchActive = (searchText.characters.count > 0)
        self.filteredResults = self.results.filter({
            if self.isPrivateChannel {
                return (($0.object as! User).displayName?.hasPrefix(searchText))!
            } else {
                return (($0.object as! Channel).displayName?.hasPrefix(searchText))!
            }
        })
        self.emptySearchLabel.isHidden = (self.filteredResults.count > 0)
        self.tableView.reloadData()
    }
}
