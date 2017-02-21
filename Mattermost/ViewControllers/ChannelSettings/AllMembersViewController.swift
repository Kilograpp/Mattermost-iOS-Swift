//
//  AllMembersViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import RealmSwift

private protocol Interface: class {
    func configureWith(channelId: String)
}

fileprivate let kSearchBarBackgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)

class AllMembersViewController: UIViewController {
    
//MARK: Properties
    @IBOutlet weak var tableView: UITableView!

    fileprivate let emptySearchLabel = EmptyDialogueLabel()
    fileprivate lazy var builder: AllMembersCellBuilder = AllMembersCellBuilder(tableView: self.tableView)
    fileprivate var searchController: UISearchController!
    
    var channel: Channel!
    var userResults: Results<User>! {
        didSet { if self.tableView != nil { self.tableView.reloadData() } }
    }
    var filteredUserResults: Results<User>! {
        didSet { if self.tableView != nil { self.tableView.reloadData() } }
    }
    var isSearchActive: Bool {
        return self.searchController != nil ? !(self.searchController.searchBar.text?.isEmpty)! : false
    }
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Interface
extension AllMembersViewController: Interface {
    func configureWith(channelId: String) {
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
        self.userResults = channel.members.sorted(byKeyPath: UserAttributes.username.rawValue)
    }
}



fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupSearchBar()
    func setupEmptyDialogueLabel()
}

fileprivate protocol Navigation: class {
    func retunToChannelSettings()
}

fileprivate protocol Request: class {
    func createDirectChannelWith(user: User)
}


//MARK: Setup
extension AllMembersViewController: Setup {
    func initialSetup(){
        setupNavigationBar()
        setupSearchBar()
        setupEmptyDialogueLabel()
    }
    
    func setupNavigationBar() {
        self.title = "All Members".localized
    }
    
    func setupSearchBar() {
        /*let textField = self.searchBar.value(forKey: "searchField") as? UITextField
        textField?.backgroundColor = ColorBucket.searchBarBackground*/
        
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
    
    func setupEmptyDialogueLabel() {
        self.emptySearchLabel.backgroundColor = self.tableView.backgroundColor
        self.emptySearchLabel.text = "No results found. Try again?"
        self.view.insertSubview(self.emptySearchLabel, aboveSubview: self.tableView)
    }
}


//MARK: Navigation
extension AllMembersViewController: Navigation {
    func retunToChannelSettings() {
        self.dismiss(animated: true) {
            let notificationName = NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification)
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}


//MARK: Request
extension AllMembersViewController: Request {
    func createDirectChannelWith(user: User) {
        Api.sharedInstance.createDirectChannelWith(user, completion: {_ in
            ChannelObserver.sharedObserver.selectedChannel = user.directChannel()
            self.retunToChannelSettings()
        })
    }
}


//MARK: UITableViewDataSource
extension AllMembersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !self.isSearchActive ? self.userResults.count : self.filteredUserResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = !self.isSearchActive ? self.userResults[indexPath.row] : self.filteredUserResults[indexPath.row]
        return self.builder.cellFor(user: user, indexPath: indexPath)
    }
}

//MARK: UITableViewDelegate
extension AllMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = !self.isSearchActive ? self.userResults[indexPath.row] : self.filteredUserResults[indexPath.row]
        guard user.identifier != Preferences.sharedInstance.currentUserId else { return }
        
        if user.directChannel() == nil {
            createDirectChannelWith(user: user)
        } else {
            ChannelObserver.sharedObserver.selectedChannel = user.directChannel()
            retunToChannelSettings()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.builder.sectionHeaderHeight()
    }
}


//MARK: Search updating
extension AllMembersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(searchText: String){
        self.filteredUserResults = self.userResults.filter(NSPredicate(format: "username CONTAINS[c] %@", searchText))
        self.emptySearchLabel.isHidden = (self.filteredUserResults.count > 0)
        self.tableView.isHidden = (self.filteredUserResults.count == 0)
    }
}
