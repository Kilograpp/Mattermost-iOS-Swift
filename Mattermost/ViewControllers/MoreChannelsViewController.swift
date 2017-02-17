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
fileprivate let kShowChatSegueIdentifier = "showChatViewController"
fileprivate let kSearchBarBackgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)

final class MoreChannelsViewController: UIViewController {
    
//MARK: Property
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    fileprivate let emptySearchLabel = EmptyDialogueLabel()
    fileprivate var results: [ResultTuple] = []
    fileprivate var filteredResults: [ResultTuple] = []
    fileprivate var updatedCahnnelIndexPaths: [IndexPath] = []
    fileprivate var searchController: UISearchController!
    
    var isPrivateChannel: Bool = false
    var isSearchActive: Bool = false
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupTableView()
}

fileprivate protocol Configuration {
    var isPrivateChannel : Bool {get set}
    func prepareResults()
}

fileprivate protocol Action {
    func backAction()
    func addDoneAction()
}

fileprivate protocol Navigation {
    func returnToChannel()
}

fileprivate protocol Request {
    func joinTo(channel: Channel)
    func leave(channel: Channel)
}

fileprivate protocol CompletionMessages {
    func singleChannelMessage(name: String)
    func multipleChannelsMessage()
    func singleUserMessage(name: String)
    func multipleUsersMessage()
}


//MARK: Setup
extension MoreChannelsViewController: Setup {
    func initialSetup() {
        prepareResults()
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupEmptyDialogueLabel()
        self.menuContainerViewController.panMode = .init(0)
    }
    
    func setupNavigationBar() {
        self.title = self.isPrivateChannel ? "Add Users".localized : "More Channel".localized
    }
    
    func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barTintColor = .white
        let view: UIView = searchController.searchBar.subviews[0] as UIView
        for subView: UIView in view.subviews {
            if let textView = subView as? UITextField {
                textView.backgroundColor = kSearchBarBackgroundColor
            }
        }
        let rect = searchController.searchBar.frame
        let lineView = UIView(frame: CGRect(x: 0, y: rect.size.height-2, width: rect.size.width, height: 2))
        lineView.backgroundColor = UIColor.white
        searchController.searchBar.addSubview(lineView)
        
        self.definesPresentationContext = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        searchController.searchBar.isTranslucent = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.register(ChannelsMoreTableViewCell.self, forCellReuseIdentifier: ChannelsMoreTableViewCell.reuseIdentifier, cacheSize: 15)
    }
    
    fileprivate func setupEmptyDialogueLabel() {
        self.emptySearchLabel.backgroundColor = self.tableView.backgroundColor
        let moreType = (self.isPrivateChannel) ? "direct chats" : "channels"
        self.emptySearchLabel.text = "No " + moreType + " found!"
        self.view.insertSubview(self.emptySearchLabel, aboveSubview: self.tableView)
    }
}


//MARK: Configuration
extension  MoreChannelsViewController: Configuration {
    func prepareResults() {
        if (self.isPrivateChannel) {
            prepareUserResults()
        } else {
            prepareChannelResults()
        }
    }
    
    func prepareChannelResults() {

        showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
        Api.sharedInstance.loadChannelsMoreWithCompletion { (channels, error) in
            self.hideLoaderView()
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            for channel in channels! {
                guard !Channel.isUserInChannelWith(channelId: channel.identifier!) else { continue }
                self.results.append((channel, false))
            }

            self.results = self.results.sorted(by: { ($0.object as! Channel).displayName! < ($1.object as! Channel).displayName! })
            self.tableView.reloadData()
        }
    }
    
    func prepareUserResults() {
        showLoaderView(topOffset: 64.0, bottomOffset: 0.0)
        
        Api.sharedInstance.loadUsersList(offset: 0) { (users, error) in
            self.hideLoaderView()
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return  }
         
            let sortName = UserAttributes.username.rawValue
            let predicate =  NSPredicate(format: "identifier != %@ AND identifier != %@", Constants.Realm.SystemUserIdentifier,
                                         Preferences.sharedInstance.currentUserId!)
            let preferedUsers = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byKeyPath: sortName, ascending: true)
            for user in preferedUsers {
                guard !user.isPreferedDirectChannel() else { continue }
                self.results.append((user, false))
            }

            self.results = self.results.sorted(by: { ($0.object as! User).displayName! < ($1.object as! User).displayName! })
            self.tableView.reloadData()
        }
    }
}


//MARK: Action
extension MoreChannelsViewController: Action {
    func backAction() {
        self.returnToChannel()
    }
    
    func addDoneAction() {
//        saveResults()
    }
}


//MARK: Navigation
extension MoreChannelsViewController: Navigation {
    func returnToChannel() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: Request
extension MoreChannelsViewController: Request {
//Public channel
    func joinTo(channel: Channel) {
        let realm = RealmUtils.realmForCurrentThread()
        try! realm.write {
            channel.team = DataManager.sharedInstance.currentTeam
            channel.computeDisplayNameWidth()
            realm.add(channel)
        }
        
        Api.sharedInstance.joinChannel(channel) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
        }
    }
    
    func leave(channel: Channel) {
        Api.sharedInstance.leaveChannel(channel) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            let nameOfDeletedChannel = channel.displayName!
            let realm = RealmUtils.realmForCurrentThread()
            try! realm.write {
                realm.delete(channel)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
        }
    }
    
//Direct channel
    func createDirectChannelWith(_ user: User) {
        Api.sharedInstance.createDirectChannelWith(user) { (channel, error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            self.updatePreferencesSave(user)
        }
    }
    
    func updatePreferencesSave(_ user: User) {
        let predicate =  NSPredicate(format: "displayName == %@", user.username!)
        let channel = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).first
        
        try! RealmUtils.realmForCurrentThread().write {
            channel?.currentUserInChannel =  true
            channel?.isDirectPrefered = true
        }
        
        var value: String
        value = Constants.CommonStrings.True
        
        let preferences: [String : String] = [ "user_id"    : (DataManager.sharedInstance.currentUser?.identifier)!,
                                               "category"   : "direct_channel_show",
                                               "name"       : user.identifier,
                                               "value"      : value
                                            ]
        
        Api.sharedInstance.savePreferencesWith(preferences) { (error) in
            guard error == nil else {
                AlertManager.sharedManager.showErrorWithMessage(message: (error?.message)!)
                return
            }
            
            Api.sharedInstance.loadTeams(with: { (userShouldSelectTeam, error) in
                guard (error == nil) else { self.hideLoaderView(); return }
                Api.sharedInstance.loadChannels { (error) in
                guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
                
                    let preferences = Preference.preferedUsersList()
                    var usersIds = [String]()
                    preferences.forEach{ usersIds.append($0.name!) }

                    Api.sharedInstance.loadUsersListBy(ids: usersIds) { (error) in
                        guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
                        let predicate = NSPredicate(format: "identifier != %@ AND identifier != %@", Preferences.sharedInstance.currentUserId!,
                                            Constants.Realm.SystemUserIdentifier)
                        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate)
                        var ids = [String]()
                        users.forEach{ ids.append($0.identifier) }
                
                        Api.sharedInstance.loadTeamMembersListBy(ids: ids) { (error) in
                            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
                            ChannelObserver.sharedObserver.selectedChannel = channel
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
                        }
                    }
                }
            })
        }
    }
}


//MARK: UITableViewDataSource
extension MoreChannelsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultTuple = self.isSearchActive ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        let cell = self.builder.cell(resultTuple: resultTuple)

        return cell
    }
}


//MARK: UITableViewDelegate
extension MoreChannelsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPrivateChannel {
         let user = (self.isSearchActive ? self.filteredResults[indexPath.row].object : self.results[indexPath.row].object) as! User
         createDirectChannelWith(user)
         return
        }
        
        let channel = (self.isSearchActive ? self.filteredResults[indexPath.row].object : self.results[indexPath.row].object) as! Channel
        joinTo(channel: channel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
}

//MARK: Search updating
extension MoreChannelsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(searchText: String){
        self.isSearchActive = (searchText.characters.count > 0)
        self.filteredResults = self.results.filter({
            if self.isPrivateChannel {
                return (($0.object as! User).username?.hasPrefix(searchText.lowercased()))!
            } else {
                return (($0.object as! Channel).displayName?.lowercased().hasPrefix(searchText.lowercased()))!
            }
        })
        self.emptySearchLabel.isHidden = (self.filteredResults.count > 0)
    }
}
