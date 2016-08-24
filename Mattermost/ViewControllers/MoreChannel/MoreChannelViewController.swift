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

final class MoreChannelViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView:  UITableView!
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    
    func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = ColorBucket.sideMenuBackgroundColor
        navigationBarAppearance.barTintColor = ColorBucket.whiteColor
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: ColorBucket.whiteColor]
        self.navigationItem.title = "More Channel"
    }
    
    func setupTableView () {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
        cell.textLabel?.text = channel?.name
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.backgroundView?.tintColor = ColorBucket.whiteColor
        cell.textLabel?.tintColor = ColorBucket.blackColor
        configureCellAtIndexPath(cell, indexPath: indexPath)
        return cell
    }
    
    func realmFetchedResultsController() -> FetchedResultsController<Channel> {
        let predicate = NSPredicate(format: "identifier != %@", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Channel>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil
        //let sortDescriptorSection = SortDescriptor(property: ChannelAttributes.privateType.rawValue, ascending: false)
        let sortDescriptorName = SortDescriptor(property: ChannelAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [/*sortDescriptorSection,*/ sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Channel>(fetchRequest: fetchRequest,
                                                                   sectionNameKeyPath: ChannelAttributes.privateType.rawValue,
                                                                            cacheName: nil)
        fetchedResultsController.delegate = nil
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
    

 
}

