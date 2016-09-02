//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift
import SwiftFetchedResultsController

final class LeftMenuViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var membersListButton: UIButton!
    var realm: Realm?
    private var resultsPublic: Results<Channel>! = nil
    private var resultsPrivate: Results<Channel>! = nil

//MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureResults()
        configureTableView()
        configureView()
        configureInitialSelectedChannel()
        configureStartUpdating()
    }

}


private protocol Configure : class {
    func configureView()
    func configureTableView()
    func configureInitialSelectedChannel()
    func configureStartUpdating()
    func configureResults()
}

private protocol Navigation : class {
    func didSelectChannelAtIndexPath(indexPath: NSIndexPath)
    func navigateToMoreChannel(section: Int)
    func toggleLeftSideMenu()
    func membersListAction(sender: AnyObject)
}

//MARK: - Configuration
extension LeftMenuViewController : Configure {
    
    private func configureView() {
        self.teamNameLabel.font = FontBucket.menuTitleFont
        self.teamNameLabel.textColor = ColorBucket.whiteColor
        self.teamNameLabel.text = DataManager.sharedInstance.currentTeam?.displayName as String!
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
    }
    
    private func configureTableView() {
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        self.tableView.registerClass(LeftMenuSectionHeader.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionHeader.reuseIdentifier)
        self.tableView.registerClass(LeftMenuSectionFooter.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionFooter.reuseIdentifier)
    }
    
    private func configureInitialSelectedChannel() {
        let indexPathForFirstRow = NSIndexPath(forRow: 0, inSection: 0) as NSIndexPath
        let initialSelectedChannel = self.resultsPublic[indexPathForFirstRow.row]
        ChannelObserver.sharedObserver.selectedChannel = initialSelectedChannel
    }
    
    private func configureStartUpdating() {
        UserStatusObserver.sharedObserver.startUpdating()
    }
    
    private func configureResults () {
        let privateTypePredicate = NSPredicate (format: "privateType == %@", Constants.ChannelType.PrivateTypeChannel)
        let publicTypePredicate = NSPredicate (format: "privateType == %@", Constants.ChannelType.PublicTypeChannel)
        let currentUserInChannelPredicate = NSPredicate(format: "currentUserInChannel == true")
        let sortName = ChannelAttributes.displayName.rawValue
        self.resultsPublic = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(publicTypePredicate).filter(currentUserInChannelPredicate).sorted(sortName, ascending: true)
        self.resultsPrivate = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(privateTypePredicate).filter(currentUserInChannelPredicate).sorted(sortName, ascending: true)
    }
    
}

//MARK: - UITableViewDataSource
extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = section == 0 ? resultsPublic.count : resultsPrivate.count
        return numberOfRowsInSection
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == 0 ? PublicChannelTableViewCell.reuseIdentifier : PrivateChannelTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LeftMenuTableViewCellProtocol
        let channel = indexPath.section == 0 ? self.resultsPublic[indexPath.row] as Channel! : self.resultsPrivate[indexPath.row] as Channel!
        cell.configureWithChannel(channel!, selected: (channel?.isSelected)!)
        cell.test = {
            //FIXME: REFACTOR:!!!!
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        
        return cell as! UITableViewCell
    }
}

//MARK: - UITableViewDelegate
extension LeftMenuViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectChannelAtIndexPath(indexPath)
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
        view.moreTapHandler = { self.navigateToMoreChannel(section) }

        return view
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(LeftMenuSectionHeader.reuseIdentifier) as! LeftMenuSectionHeader
        let sectionName = section == 0 ? Constants.ChannelType.PublicTypeChannel : Constants.ChannelType.PrivateTypeChannel
        view.configureWithChannelType(Channel.privateTypeDisplayName(sectionName))
        view.addTapHandler = { print("ADD CHANNEL") }
        
        return view
    }

}

//MARK: - Navigation
extension LeftMenuViewController : Navigation {
    
    private func didSelectChannelAtIndexPath(indexPath: NSIndexPath) {
        let selectedChannel = indexPath.section == 0 ? self.resultsPublic[indexPath.row] as Channel : self.resultsPrivate[indexPath.row] as Channel
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel
        self.tableView.reloadData()
        toggleLeftSideMenu()
    }
    
    private func navigateToMoreChannel(section: Int)  {
        let moreViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MoreChannelsViewController") as! MoreChannelsViewController
        moreViewController.isPrivateChannel = (section == 0) ? false : true
        self.menuContainerViewController!.centerViewController.pushViewController(moreViewController, animated: true)
        toggleLeftSideMenu()
    }
    
    private func toggleLeftSideMenu() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    @IBAction func membersListAction(sender: AnyObject) {
        print("MEMBERS_LIST")
    }

}

