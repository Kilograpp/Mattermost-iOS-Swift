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

final class MembersViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var searchController = UISearchController()
    var strategy = MembersStrategy()
    private var userList: Results<User>! = nil
    var channel: Channel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        setupSearchController()
        
        //place to other REFACTOR
        self.userList = RealmUtils.realmForCurrentThread().objects(User.self).filter(self.strategy.predicateWithChannel(channel!))
    }
    
}
//MARK: - Setup
private protocol Setup {
    func setupNavigationBar()
    func setupTableView()
    func setupSearchController()
}

extension MembersViewController: Setup {
    func setupNavigationBar() {
        self.navigationItem.title = self.strategy.title()
        if (self.strategy.shouldShowRightBarButtonItem()) {
            setupRightBarButtonItem()
        }
    }
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.view.backgroundColor = ColorBucket.whiteColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                 style: UIBarButtonItemStyle.Plain,
                                                                 target: self,
                                                                 action: #selector(save))
    }
}

extension MembersViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.delegate = self
        self.searchController.searchBar.backgroundImage = UIImage()
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.searchController.searchBar.scopeButtonTitles = []
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchController.searchBar.backgroundColor = ColorBucket.whiteColor
        self.searchController.searchBar.translucent = false

        
        self.tableView.tableHeaderView = self.searchController.searchBar
    }
    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //REFACTOR
        let containsPredicate = self.strategy.predicateWithChannel(self.channel!)
        if let searchString = searchController.searchBar.text {
            let namePredicate = NSPredicate(format: "self.nickname contains[c] %@", searchString)
            let resultPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, containsPredicate])
            self.userList = RealmUtils.realmForCurrentThread().objects(User.self).filter(resultPredicate)
        } else {
            self.userList = RealmUtils.realmForCurrentThread().objects(User.self).filter(containsPredicate)
        }
    }
}


//MARK: - UITableViewDataSource
extension MembersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = userList[indexPath.row].nickname
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
}
//MARK: - UITableViewDelegate
extension MembersViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.strategy.isAddMembers()) {
            self.strategy.didSelectUser(userList[indexPath.row])
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
}

extension MembersViewController {
    func save() {
        print("SAVE")
    }
}