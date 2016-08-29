//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftFetchedResultsController

class MoreChannelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    var realm: Realm?
    internal var isPriviteChannel : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        realmFetchedResultsController()
        setupTableView()
    }
    
    
    func setupNavigationBar() {
        self.title = "More Channel"
    }
    
    func setupTableView () {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
}

extension MoreChannelViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showChatViewController", sender: self.fetchedResultsController.objectAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showChatViewController") {
            guard let selectedChannel = sender else { return }
            ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
        }
    }
}

extension MoreChannelViewController : UITableViewDataSource {

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.isPriviteChannel != nil && self.isPriviteChannel == true) {
            if (section == 1) {
                return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
            }
            
        } else {
            if (section == 0) {
                return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
            }
            
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.backgroundView?.tintColor = ColorBucket.whiteColor
        cell.textLabel?.tintColor = ColorBucket.blackColor
        configureCellAtIndexPath(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        if (self.isPriviteChannel != nil && self.isPriviteChannel == true) {
            if (indexPath.section == 1) {
                let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
                cell.textLabel?.text = channel?.displayName
            }

        } else {
            if (indexPath.section == 0) {
                let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
                cell.textLabel?.text = channel?.displayName
            }
        }
    }
}

extension MoreChannelViewController  {
    func realmFetchedResultsController() -> FetchedResultsController<Channel> {
        let predicate = NSPredicate(format: "identifier != %@", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Channel>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil

        let sortDescriptorSection = SortDescriptor(property: ChannelAttributes.privateType.rawValue, ascending: false)
        let sortDescriptorName = SortDescriptor(property: ChannelAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorSection, sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Channel>(fetchRequest: fetchRequest,
                                                                         sectionNameKeyPath: ChannelAttributes.privateType.rawValue,
                                                                         cacheName: nil)
        fetchedResultsController.delegate = nil
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
}
