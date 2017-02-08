//
//  AllMembersViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import RealmSwift

class AllMembersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var channel: Channel!
    var membersList: Results<User>!
    var searchMembersList: Results<User>!
    
    var lastSelectedIndexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
}

fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupSearchBar()
    func setupTableView()
}

fileprivate protocol Action {
    func backAction()
}

//MARK: Setup
extension AllMembersViewController: Setup {
    func initialSetup(){
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        membersList = channel.members.sorted(byKeyPath: UserAttributes.username.rawValue)
        let nib = UINib(nibName: "MemberChannelSettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "memberChannelSettingsCell")
    }
    func setupTableView() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
    }
    func setupNavigationBar() {
        self.title = "All Members".localized
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupSearchBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barTintColor = .white
        let view: UIView = searchController.searchBar.subviews[0] as UIView
        for subView: UIView in view.subviews {
            if let textView = subView as? UITextField {
                textView.backgroundColor = UIColor(red:     239.0/255.0,
                                                   green:   239.0/255.0,
                                                   blue:    244.0/255.0,
                                                   alpha:   1.0)
            }
        }
        let rect = searchController.searchBar.frame
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: rect.size.height-2, width: rect.size.width, height: 2))
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
        
        let membersIdentifiers = Array(membersList.map{$0.identifier!})
        let sortName = UserAttributes.username.rawValue
        
        let predicate =  NSPredicate(format: "username CONTAINS[c] '\(searchText)' AND identifier IN %@", membersIdentifiers)
        searchMembersList = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byKeyPath: sortName)
    }
}

//MARK: UITableViewDataSource
extension AllMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? searchMembersList.count : membersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //CODEREVIEW WTF????
        var cell: UITableViewCell!
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "memberChannelSettingsCell") as! MemberChannelSettingsCell
        let member = searchController.isActive ? searchMembersList[indexPath.row] : membersList[indexPath.row]
        memberCell.configureWithUser(user: member)
        cell = memberCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

//MARK: UITableViewDelegate
extension AllMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.lastSelectedIndexPath == nil else { return }
        self.lastSelectedIndexPath = indexPath
        
        let member = searchController.isActive ? searchMembersList[indexPath.row] : membersList[indexPath.row]
        self.searchController.isActive = false
        
        if member.identifier == Preferences.sharedInstance.currentUserId!{
            self.lastSelectedIndexPath = nil
            return
        }
        if member.directChannel() == nil {
            Api.sharedInstance.createDirectChannelWith(member, completion: {_ in
                ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
                self.dismiss(animated: true, completion: {
                    self.lastSelectedIndexPath = nil
                })
            })
        } else {
            ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
            self.dismiss(animated: true, completion: {
                self.lastSelectedIndexPath = nil
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
            })
        }
    }
}

//MARK: Action
extension AllMembersViewController: Action {
    func backAction(){
        _=self.navigationController?.popViewController(animated: true)
    }
}

