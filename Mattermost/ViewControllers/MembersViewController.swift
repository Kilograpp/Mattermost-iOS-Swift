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
//MARK: - Setup
private protocol Setup {
    func setupNavigationBar()
    func setupTableView()
    func setupSearchController()
    func setupUsers()
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
    func setupUsers() {
        self.users = RealmUtils.realmForCurrentThread().objects(User.self).filter(self.strategy.predicateWithChannel(channel!))
    }
}

extension MembersViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func setupSearchController() {
        self.extendedLayoutIncludesOpaqueBars = true    // add edges to searchBar (on top) ..
        self.edgesForExtendedLayout = UIRectEdge.None   //   ..   equals 0
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.searchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        self.searchController.delegate = self
        self.searchController.searchBar.translucent = false
        self.searchController.searchBar.backgroundColor = ColorBucket.whiteColor
    }
    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let containsPredicate = self.strategy.predicateWithChannel(self.channel!)
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
        //REFACTOR билдер
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = users[indexPath.row].displayName
//        cell?.accessoryType = .DetailDisclosureButton
        cell?.accessoryView = UIImageView(image:strategy.imageForCellAccessoryViewWithUser(users[indexPath.row]))
//        cell?.imageView?.image = /=*_*=/
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
}
//MARK: - UITableViewDelegate
extension MembersViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.strategy.isAddMembers()) {
            //refactor  this V user -> let user
            self.strategy.didSelectUser(users[indexPath.row])
            self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryView = UIImageView(image:strategy.imageForCellAccessoryViewWithUser(users[indexPath.row]))
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            print(users[indexPath.row])
        }
    }
}

extension MembersViewController {
    func save() {
        strategy.addUsersToChannel(channel!) { (error) in
            print("Users added to Channel")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}