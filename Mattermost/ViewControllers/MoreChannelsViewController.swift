//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class MoreChannelsViewController: UIViewController {
    
//MARK: Property
    
    @IBOutlet weak var tableView: UITableView!
    
    var realm: Realm?
    fileprivate lazy var builder: MoreCellBuilder = MoreCellBuilder(tableView: self.tableView)
    fileprivate let showChatViewController = "showChatViewController"
    
    fileprivate var results: Results<Channel>! = nil
    fileprivate var filteredResults: Results<Channel>! = nil
    
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

private protocol MoreChannelsViewControllerRequests {
    func loadChannels()
}

private protocol MoreChannelsViewControllerAction {
    func backAction()
    func addDoneAction()
}

private protocol MoreChannelsViewControllerNavigation {
    func returnToChannel()
}

//MARK: LifeCycle

extension MoreChannelsViewController: MoreChannelsViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        prepareResults()
        loadChannels()
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
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.DirectTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
        
        print("channels = ", self.results.count)
        
        let users = RealmUtils.realmForCurrentThread().objects(User.self)
        print("users = ", users.count)
    }
}


extension MoreChannelsViewController: MoreChannelsViewControllerRequests {
    func loadChannels() {
        Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
}


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
        for channel in self .results {
            RealmUtils.save(channel)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification), object: nil)
    }
}


//MARK: Navigation

extension MoreChannelsViewController: MoreChannelsViewControllerNavigation {
    func returnToChannel() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK: UITableViewDataSource

extension MoreChannelsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isSearchActive) ? self.filteredResults.count : self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = (self.isSearchActive) ? self.filteredResults[indexPath.row] : self.results[indexPath.row]
        let cell = self.builder.cellFor(channel: channel)

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
        let predicate = NSPredicate(format: "displayName BEGINSWITH[c] %@", searchText)
        self.filteredResults = self.results.filter(predicate)
        self.tableView.reloadData()
    }
}
