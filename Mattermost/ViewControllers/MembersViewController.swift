//
//  MembersViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import SwiftFetchedResultsController
import RealmSwift

let membersCellHeight: CGFloat = 61

final class MembersViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var strategy = MembersStrategy()
    var channel: Channel?
    private lazy var builder: MembersCellBuilder = MembersCellBuilder(tableView: self.tableView)
    private var searchController = UISearchController(searchResultsController: nil)
    private var users: Results<User>! = nil
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        setupSearchController()
        setupUsers()
    }
    
}

private protocol Setup {
    func setupNavigationBar()
    func setupTableView()
    func setupSearchController()
    func setupUsers()
}
//MARK: - Setup
extension MembersViewController: Setup {
    func setupNavigationBar() {
        navigationItem.title = strategy.title()
        if (strategy.shouldShowRightBarButtonItem()) {
            setupRightBarButtonItem()
        }
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = ColorBucket.whiteColor
        view.backgroundColor = ColorBucket.whiteColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(MembersTableViewCell.self, forCellReuseIdentifier: MembersTableViewCell.reuseIdentifier, cacheSize: 5)
    }
    
    func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(saveAction))
    }
    func setupUsers() {
        users = RealmUtils.realmForCurrentThread().objects(User.self).filter(self.strategy.predicateWithChannel(channel!))
    }
}

//MARK: - UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate
extension MembersViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func setupSearchController() {
        extendedLayoutIncludesOpaqueBars = true    // add edges to searchBar (on top) ..
        edgesForExtendedLayout = .None   //   ..   equals 0
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.translucent = false
        searchController.searchBar.backgroundColor = ColorBucket.whiteColor
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let containsPredicate = strategy.predicateWithChannel(channel!)
        if let searchString = searchController.searchBar.text {
            let namePredicate = NSPredicate(format: "displayName contains[c] %@", searchString)
            let resultPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, containsPredicate])
            users = RealmUtils.realmForCurrentThread().objects(User.self).filter(resultPredicate)
        } else {
            users = RealmUtils.realmForCurrentThread().objects(User.self).filter(containsPredicate)
        }
        tableView.reloadData()
    }
}


//MARK: - UITableViewDataSource
extension MembersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return membersCellHeight
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return builder.cellForMember(users[indexPath.row],strategy: strategy)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
}
//MARK: - UITableViewDelegate
extension MembersViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (strategy.isAddMembers()) {
            let user = users[indexPath.row]
            strategy.didSelectUser(user)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryView = UIImageView(image:strategy.imageForCellAccessoryViewWithUser(user))
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
}

extension MembersViewController {
    //MARK: - Action
    func saveAction() {
        strategy.addUsersToChannel(channel!) { (error) in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}