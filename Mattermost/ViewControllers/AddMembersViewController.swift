//
//  AddMembersViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class AddMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating  {

    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        setupSearchBar()
        
        let nib = UINib(nibName: "MemberInAdditingCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "memberInAdditingCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "memberInAdditingCell") as! MemberInAdditingCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 1.0
    }
    
    func setupNavigationBar() {
        self.title = "Add Members".localized
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
        
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        searchController.searchBar.isTranslucent = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }

    
    //Search updating
    func updateSearchResults(for searchController: UISearchController) {

    }
    
}
