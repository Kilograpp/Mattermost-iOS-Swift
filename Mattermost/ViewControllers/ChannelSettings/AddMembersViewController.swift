//
//  AddMembersViewController.swift
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


class AddMembersViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var emptyDialogueLabel = EmptyDialogueLabel()
    
    fileprivate lazy var builder: AddMembersCellBuilder = AddMembersCellBuilder(tableView: self.tableView)
    
    var channel: Channel!
    var users: Array<User>! = Array() {
        didSet { if self.tableView != nil { self.tableView.reloadData() } }
    }
    var searchUsers: Array<User>! = Array() {
        didSet { if self.tableView != nil { self.tableView.reloadData() } }
    }
    
    var isSearchActive: Bool { return !(searchBar.text?.isEmpty)! }
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Interface
extension AddMembersViewController: Interface {
    func configureWith(channelId: String) {
        self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
        loadUsersAreNotInChannel()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupSearchBar()
    func setupEmptyDialogLabel()
}

fileprivate protocol Request: class {
    func loadUsersAreNotInChannel()
    func addToChannel(user: User)
}


//MARK: Setup
extension AddMembersViewController: Setup {
    func initialSetup() {
        tableView.tableFooterView = UIView(frame: .zero)
        setupNavigationBar()
        setupSearchBar()
        setupEmptyDialogLabel()
    }
    
    func setupNavigationBar() {
        self.title = "Add Members".localized
    }
    
    func setupSearchBar() {
        let textField = self.searchBar.value(forKey: "searchField") as? UITextField
        textField?.backgroundColor = ColorBucket.searchBarBackground
    }
    
    func setupEmptyDialogLabel() {
        emptyDialogueLabel = EmptyDialogueLabel(channel: self.channel, type: 1)
        emptyDialogueLabel.text = "No users to add"
        emptyDialogueLabel.font = FontBucket.feedbackTitleFont
        emptyDialogueLabel.backgroundColor = .clear
        self.view.insertSubview(self.emptyDialogueLabel, aboveSubview: self.tableView)
    }
}


//MARK: Request
extension AddMembersViewController: Request {
    func loadUsersAreNotInChannel() {
        Api.sharedInstance.loadUsersAreNotIn(channel: self.channel, completion: { (error, users) in
            guard (error == nil) else { self.handleErrorWith(message: (error?.message)!); return }
            self.users = users!
        })
    }
    
    func addToChannel(user: User) {
        let channelId = self.channel.identifier
        Api.sharedInstance.addUserToChannel(user, channel: channel, completion: { (error) in
            guard (error == nil) else { self.handleErrorWith(message: (error?.message)!); return }
            
            self.channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
            
            var index = self.users.index(where: { $0.identifier == user.identifier })
            if index != NSNotFound && index != nil { self.users.remove(at: index!) }
            
            index = self.searchUsers.index(where: { $0.identifier == user.identifier })
            if index != NSNotFound && index != nil { self.searchUsers.remove(at: index!) }
            
            self.tableView.reloadData()
            
            let channelType = self.channel.privateType == "P" ? "group" : "channel"
            self.handleSuccesWith(message: user.username! + " was added in " + channelType)
            
            if self.isSearchActive {
                self.searchBar.text = ""
                self.searchBar.resignFirstResponder()
            }
        })
    }
}



//MARK: UITableViewDataSource
extension AddMembersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users.count == 0 || (self.searchUsers.count == 0 && self.isSearchActive) {
            emptyDialogueLabel.isHidden = false
        } else {
            emptyDialogueLabel.isHidden = true
        }
        return !self.isSearchActive ? self.users.count : self.searchUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = !self.isSearchActive ? self.users[indexPath.row] : self.searchUsers[indexPath.row]
        return self.builder.cellFor(user: user, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension AddMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = !self.isSearchActive ? self.users[indexPath.row] : self.searchUsers[indexPath.row]
        addToChannel(user: user)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.builder.sectionHeaderHeight()
    }
}


//MARK: UISearchBarDelegate
extension AddMembersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchUsers = users.filter({
            $0.username?.lowercased().range(of: searchText.lowercased()) != nil || searchText == ""
        })
    }
}
