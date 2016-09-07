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
    
//MARK: - Property
    @IBOutlet weak var tableView: UITableView!
    var realm: Realm?
    var isPrivateChannel : Bool = false
    private let showChatViewController = "showChatViewController"
    private var results: Results<Channel>! = nil
    
//MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        configureResults()
        loadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}

//MARK: - PrivateProtocols
private protocol Setup : class {
    func setupNavigationBar()
    func setupTableView()
}

private protocol Configure : class {
    var isPrivateChannel : Bool {get set}
    func configureResults()
    func loadData()
}

//MARK: - UITableViewDataSource
extension MoreChannelsViewController : UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MoreChannelsTableViewCell.reuseIdentifier) as! MoreChannelsTableViewCell
        let channel = self.results[indexPath.row] as Channel?
        cell.configureCellWithObject(channel!)
        return cell
    }
    
}

//MARK: - UITableViewDelegate

extension MoreChannelsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(showChatViewController, sender: self.results[indexPath.row])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MoreChannelsTableViewCell.height()
    }

}

//MARK: - Setup
extension MoreChannelsViewController: Setup {

    func setupNavigationBar() {
        self.title = "More Channel".localized
        
    }
    
    func setupTableView () {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.registerNib(MoreChannelsTableViewCell.nib, forCellReuseIdentifier: MoreChannelsTableViewCell.reuseIdentifier)
    }
}

//MARK: - Configure
extension  MoreChannelsViewController: Configure  {
    func configureResults() {
        
        let typeValue = self.isPrivateChannel ? Constants.ChannelType.PrivateTypeChannel : Constants.ChannelType.PublicTypeChannel
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(sortName, ascending: true)
    }
    
    func loadData(){
       Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.configureResults()
            self.tableView.reloadData()
        }
    }

}
