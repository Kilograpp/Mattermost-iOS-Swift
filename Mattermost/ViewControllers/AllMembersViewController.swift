//
//  AllMembersViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class AllMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating   {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var channel: Channel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        setupSearchBar()
        
        let nib = UINib(nibName: "MemberChannelSettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "memberChannelSettingsCell")
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
        return channel.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let memberCell = tableView.dequeueReusableCell(withIdentifier: "memberChannelSettingsCell") as! MemberChannelSettingsCell
        memberCell.configureWithUser(user: channel.members[indexPath.row])
        cell = memberCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func setupNavigationBar() {
        self.title = "All Members".localized
        /*
         let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon"), style: .done, target: self, action: #selector(backAction))
         self.navigationItem.leftBarButtonItem = backButton*/
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func backAction(){
        _=self.navigationController?.popViewController(animated: true)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = channel.members[indexPath.row]
        
        if member.directChannel() == nil{
            Api.sharedInstance.createDirectChannelWith(member, completion: {_ in
                ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            ChannelObserver.sharedObserver.selectedChannel = member.directChannel()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Search updating
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
