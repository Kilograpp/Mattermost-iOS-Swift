//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift
import UITableView_Cache
import SwiftFetchedResultsController

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    var realm: Realm?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
    }
    
    private func configureTableView() -> Void {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
}

extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "cell")
        var channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
        print("\(channel?.privateType)")
        cell.textLabel?.text = channel!.displayName!
        
        return cell
    }
}

extension LeftMenuViewController : UITableViewDelegate {
    
}

extension LeftMenuViewController {
    // MARK: - FetchedResultsController
    
    func realmFetchedResultsController() -> FetchedResultsController<Channel> {
        let predicate = NSPredicate(format: "identifier != %@", "fds")
        let realm = try! Realm()
        let fetchRequest = FetchRequest<Channel>(realm: realm, predicate: predicate)
        fetchRequest.predicate = nil
        let sortDescriptorSection = SortDescriptor(property: ChannelAttributes.privateType.rawValue, ascending: false)
        let sortDescriptorName = SortDescriptor(property: ChannelAttributes.displayName.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorSection, sortDescriptorName]
        let fetchedResultsController = FetchedResultsController<Channel>(fetchRequest: fetchRequest, sectionNameKeyPath: ChannelAttributes.privateType.rawValue, cacheName: nil)
        fetchedResultsController.delegate = nil//self
        fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }
}
