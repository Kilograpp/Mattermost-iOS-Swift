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
    
    var realm: Realm?
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    fileprivate let showChatViewController = "showChatViewController"
    
    fileprivate var results: Array<ResultTuple>! = Array()
    fileprivate var filteredResults: Array<ResultTuple>! = Array()
    
    
   // fileprivate var results: Results<Channel>! = nil
    //fileprivate var filteredResults: Results<Channel>! = nil
    
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

/*private protocol MoreChannelsViewControllerRequests {
    func loadChannels()
}*/

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
        }
        else {
            loadAllChannels()
        }
        
       // loadChannels()
    }
}


//MARK: Setup

extension MoreChannelsViewController: MoreChannelsViewControllerSetup {
    func initialSetup() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        self.title = self.isPrivateChannel ? "Add Users".localized : "More Channel".localized
        
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let addDoneTitle = self.isPrivateChannel ? "Done".localized : "Add".localized
        let addDoneButton = UIBarButtonItem.init(title: addDoneTitle, style: .done, target: self, action: #selector(addDoneAction))
        self.navigationItem.rightBarButtonItem = addDoneButton
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.register(ChannelsMoreTableViewCell.self, forCellReuseIdentifier: ChannelsMoreTableViewCell.reuseIdentifier, cacheSize: 10)
    }
}


//MARK: Configuration

extension  MoreChannelsViewController: MoreChannelsViewControllerConfiguration  {
    func prepareResults() {
        if (self.isPrivateChannel) {
            prepareUserResults()
        }
        else {
            prepareChannelResults()
        }
        
        /*
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        
        print(self.results[0])
        
        let users = RealmUtils.realmForCurrentThread().objects(User.self)
        
        for user in users {
            
        }
        
        print("users = ", users.count)*/
    }
    
    func prepareChannelResults() {
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        let channels = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
     //   self.results.removeAll()
        for channel in channels {
            self.results?.append((channel, channel.currentUserInChannel))
        }
    }
    
    func prepareUserResults() {
        let sortName = UserAttributes.username.rawValue
        let predicate =  NSPredicate(format: "identifier != %@", Constants.Realm.SystemUserIdentifier)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
     //   self.results.removeAll()
        for user in users {
            self.results?.append((user, user.hasChannel()))
        }
    }
    
    func saveResults() {
        if self.isPrivateChannel {
            saveUserResults()
        }
        else {
            saveChannelResults()
        }
    }
    
    func saveChannelResults() {
        for resultTuple in self.results {
            let channel = (resultTuple.object as! Channel)
            guard (channel.currentUserInChannel != resultTuple.checked) else { continue }
            
            if resultTuple.checked {
                joinTo(channel: channel)
            }
            else {
                leave(channel: channel)
            }
        }
    }
    
    func saveUserResults() {
        for resultTuple in self.results {
            if !(resultTuple.object as! User).hasChannel() {
                createDirectChannelWith(result: resultTuple)
            }
            else {
                updatePreferencesSave(result: resultTuple)
            }
        }
    }
}

/*
extension MoreChannelsViewController: MoreChannelsViewControllerRequests {
    func loadChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
}*/


//MARK: Action

extension MoreChannelsViewController: MoreChannelsViewControllerAction {
    func backAction() {
        //loadChannels()
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
         //   self.prepareResults()
         //   self.tableView.reloadData()
            self.returnToChannel()
        }
    }
    
    func addDoneAction() {
      //  for channel in self.results {
       //     RealmUtils.save(channel)
//        }
        
        saveResults()
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
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
            self.prepareResults()
            self.tableView.reloadData()
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
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
    
    func leave(channel: Channel) {
        Api.sharedInstance.leaveChannel(channel) { (error) in
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
    
    func createDirectChannelWith(result: ResultTuple) {
        guard  (result.checked != (result.object as! User).hasChannel()) else { return }
        
        Api.sharedInstance.createDirectChannelWith((result.object as! User)) { (channel, error) in
            guard (error == nil) else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
            
            self.updatePreferencesSave(result: result)
            print(channel)
        }
    }
    
    func updatePreferencesSave(result: ResultTuple) {
        
        let user = (result.object as! User)
        let predicate =  NSPredicate(format: "displayName == %@", user.username!)
        let channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).first
        
        try! RealmUtils.realmForCurrentThread().write {
            channel?.currentUserInChannel = result.checked ? true : false
        }
        
        let preferences: Dictionary<String, String> = [ "category" : "direct_channel_show",
                            "name" : (result.object as! User).identifier,
                            "user_id" : (DataManager.sharedInstance.currentUser?.identifier)!,
                            "value" : result.checked ? "true" : "false"
        ]
        
        Api.sharedInstance.savePreferencesWith(preferences) { (error) in
            guard (error == nil) else {
                //AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!, viewController: self)
                return
            }
        }
    }
}


//MARK: UITableViewDataSource

extension MoreChannelsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count = ", self.results.count)
        print("countFiltered = ", self.filteredResults.count)
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var resultTuple = self.isSearchActive ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        let cell = self.builder.cellFor(resultTuple: resultTuple)
        (cell as! ChannelsMoreTableViewCell).checkBoxHandler = {
            resultTuple.checked = !resultTuple.checked
            if self.isSearchActive {
                self.filteredResults[indexPath.row] = resultTuple
                let realIndex = self.results.index(where: { return ($0.object == resultTuple.object) })
                self.results[realIndex!] = resultTuple
            }
            else {
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
        self.isSearchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
        self.tableView.reloadData()
        self.filteredResults = nil;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.isSearchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredResults = self.results.filter({
            if self.isPrivateChannel {
                return (($0.object as! User).displayName?.hasPrefix(searchText))!
            }
            else {
                return (($0.object as! Channel).displayName?.hasPrefix(searchText))!
            }
        })
        self.tableView.reloadData()
    }
}
