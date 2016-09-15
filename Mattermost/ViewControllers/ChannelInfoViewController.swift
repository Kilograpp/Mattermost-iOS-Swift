//
//  ChannelInfoViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 08.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftFetchedResultsController

final class ChannelInfoViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var displayManager : ChannelDisplayManager?
    var channel: Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupTitle()
    }
}
private protocol Setup {
    func setupTableView()
    func setupTitle()
}

//MARK: - Setup
extension ChannelInfoViewController: Setup {
    func setupTableView() {
        displayManager = ChannelDisplayManager(tableView: tableView, channel:channel!)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTitle(){
        title = "Channel info"
    }
    
    //todo close button
}

//MARK: - UITableViewDelegate
extension ChannelInfoViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return displayManager!.heightForRowAtIndexPath(indexPath)
    }
    
    //todo didSelect
}

//MARK: - UITableViewDataSource
extension ChannelInfoViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayManager!.numberOfRowsInSection(section)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return displayManager!.numberOfSections()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (displayManager?.cellForIndexPath(indexPath))!
    }
}

