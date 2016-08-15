//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift
import SwiftFetchedResultsController

class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchedResultsController: FetchedResultsController<Channel> = self.realmFetchedResultsController()
    var realm: Realm?

    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var membersListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.configureView()
        self.configureInitialSelectedChannel()
        
        UserStatusObserver.sharedObserver.startUpdating()
    }
    
    func test() {

    }
    
    
    //MARK: - Configuration
    
    private func configureView() {
        self.teamNameLabel.font = FontBucket.menuTitleFont
        self.teamNameLabel.textColor = ColorBucket.whiteColor
        self.teamNameLabel.text = DataManager.sharedInstance.currentTeam?.displayName as String!
        
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
    }
    
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        self.tableView.registerClass(LeftMenuSectionHeader.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionHeader.reuseIdentifier)
        self.tableView.registerClass(LeftMenuSectionFooter.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionFooter.reuseIdentifier)
    }
    
    private func configureInitialSelectedChannel() {
        let indexPathForFirstRow = NSIndexPath(forRow: 0, inSection: 0) as NSIndexPath
        let initialSelectedChannel = self.fetchedResultsController.objectAtIndexPath(indexPathForFirstRow)
        ChannelObserver.sharedObserver.selectedChannel = initialSelectedChannel
    }
    
    
    //MARK: - Private
    
    private func didSelectChannelAtIndexPath(indexPath: NSIndexPath) -> Void {
        let selectedChannel = self.fetchedResultsController.objectAtIndexPath(indexPath)! as Channel
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel
        self.tableView.reloadData()
        self.toggleLeftSideMenu()
    }
    
    private func toggleLeftSideMenu() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
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
        let reuseIdentifier = indexPath.section == 0 ? PublicChannelTableViewCell.reuseIdentifier : PrivateChannelTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LeftMenuTableViewCellProtocol
        let channel = self.fetchedResultsController.objectAtIndexPath(indexPath) as Channel?
        cell.configureWithChannel(channel!, selected: (channel?.isSelected)!)
        cell.test = { [unowned cell] in
//            self.tableView.beginUpdates()
            self.tableView.reloadData()
//            cell.reloadCell()
//            self.tableView.endUpdates()
        }
        
        return cell as! UITableViewCell
    }
}

extension LeftMenuViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectChannelAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(LeftMenuSectionFooter.reuseIdentifier) as! LeftMenuSectionFooter
        view.moreTapHandler = {print("MORE CHANNELS")}

        return view
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(LeftMenuSectionHeader.reuseIdentifier) as! LeftMenuSectionHeader
        let sectionName = self.fetchedResultsController.titleForHeaderInSection(section)
        view.configureWithChannelType(Channel.privateTypeDisplayName(sectionName))
        view.addTapHandler = {print("ADD CHANNEL")}
        
        return view
    }
    
    //MARK: - Actions
    
    @IBAction func membersListAction(sender: AnyObject) {
        print("MEMBERS_LIST")
    }
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
