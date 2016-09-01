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
    
    @IBOutlet weak var tableView: UITableView!

    var realm: Realm?
    // FIXME: Code Review: Вынести в приватный протокол интерфейсных методов
    var isPrivateChannel : Bool = false
    private let showChatViewController = "showChatViewController"
    private let privateTypeChannel = "D"
    private let publicTypeChannel = "O"
    private var results: Results<Channel>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        prepareResults()
        loadFitsPageOfData()
    }
    
// FIXME: Code Review: В приватные методы с приватным протоколом(Configuration), который объявляется после класса

//MARK: Setup
    func setupNavigationBar() {
        self.title = "More Channel".localized

    }
    
    // FIXME: Code Review: В приватные методы
    func setupTableView () {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.registerNib(MoreChannelsTableViewCell.nib(), forCellReuseIdentifier: MoreChannelsTableViewCell.reuseIdentifier())
    }
    
//MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
    
}

//MARK: UITableViewDataSource
extension MoreChannelsViewController : UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MoreChannelsTableViewCell.reuseIdentifier()) as! MoreChannelsTableViewCell
        let channel = self.results[indexPath.row] as Channel?
        cell.configureCellWithObject(channel!)
        return cell
    }
    
}

//MARK: UITableViewDelegate

extension MoreChannelsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(showChatViewController, sender: self.results[indexPath.row])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MoreChannelsTableViewCell.height()
    }

}

extension MoreChannelsViewController  {
    func prepareResults() {
        
        //Preferences.sharedInstance.currentUserId
        let typeValue = self.isPrivateChannel ? privateTypeChannel : publicTypeChannel
       // let userInTheChannel = Preferences.sharedInstance.currentUserId in ChannelRelationships.members.hashValue
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(sortName, ascending: true)
    }
    
    func loadFitsPageOfData(){
       Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
 
}
