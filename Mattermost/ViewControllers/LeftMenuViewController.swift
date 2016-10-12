//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift

final class LeftMenuViewController: UIViewController {

//MARK: - Property
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var membersListButton: UIButton!
    var realm: Realm?
    fileprivate var resultsPublic: Results<Channel>! = nil
    fileprivate var resultsPrivate: Results<Channel>! = nil

//MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureResults()
        configureTableView()
        configureView()
        configureInitialSelectedChannel()
        configureStartUpdating()
        setupChannelsObserver()
    }
    
    //refactor later -> ObserverUtils
    func setupChannelsObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateResults),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification),
                                               object: nil)
    }
    
    func updateResults() {
        configureResults()
        self.tableView.reloadData()
    }
    
}

//MARK: - PrivateProtocols

private protocol Configure : class {
    func configureView()
    func configureTableView()
    func configureInitialSelectedChannel()
    func configureStartUpdating()
    func configureResults()
}

private protocol Navigation : class {
    func didSelectChannelAtIndexPath(_ indexPath: IndexPath)
    func navigateToMoreChannel(_ section: Int)
    func toggleLeftSideMenu()
    func membersListAction(_ sender: AnyObject)
}

//MARK: - Configuration
extension LeftMenuViewController : Configure {
    
    fileprivate func configureView() {
        self.teamNameLabel.font = FontBucket.menuTitleFont
        self.teamNameLabel.textColor = ColorBucket.whiteColor
        self.teamNameLabel.text = DataManager.sharedInstance.currentTeam?.displayName as String!
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
    }
    
    fileprivate func configureTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        self.tableView.register(LeftMenuSectionHeader.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionHeader.reuseIdentifier)
        self.tableView.register(LeftMenuSectionFooter.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionFooter.reuseIdentifier)
    }
    
    fileprivate func configureInitialSelectedChannel() {
        let indexPathForFirstRow = IndexPath(row: 0, section: 0) as IndexPath
        let initialSelectedChannel = self.resultsPublic[indexPathForFirstRow.row]
        ChannelObserver.sharedObserver.selectedChannel = initialSelectedChannel
    }
    
    fileprivate func configureStartUpdating() {
        // UserStatusObserver Updating
//        UserStatusObserver.sharedObserver.startUpdating()
    }
    
    fileprivate func configureResults () {
        let privateTypePredicate = NSPredicate (format: "privateType == %@", Constants.ChannelType.PrivateTypeChannel)
        let publicTypePredicate = NSPredicate (format: "privateType == %@", Constants.ChannelType.PublicTypeChannel)
        let currentUserInChannelPredicate = NSPredicate(format: "currentUserInChannel == true")
        let sortName = ChannelAttributes.displayName.rawValue
        self.resultsPublic =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(publicTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsPrivate =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(privateTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
    }
    
}

//MARK: - UITableViewDataSource
extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = section == 0 ? resultsPublic.count : resultsPrivate.count
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == 0 ? PublicChannelTableViewCell.reuseIdentifier : PrivateChannelTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LeftMenuTableViewCellProtocol
        let channel = (indexPath as NSIndexPath).section == 0 ? self.resultsPublic[indexPath.row] as Channel! : self.resultsPrivate[indexPath.row] as Channel!
        cell.configureWithChannel(channel!, selected: (channel?.isSelected)!)
        cell.test = {
            //FIXME: REFACTOR:!!!!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        return cell as! UITableViewCell
    }
}

//MARK: - UITableViewDelegate
extension LeftMenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectChannelAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionFooter.reuseIdentifier) as! LeftMenuSectionFooter
        view.moreTapHandler = { self.navigateToMoreChannel(section) }

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionHeader.reuseIdentifier) as! LeftMenuSectionHeader
        let sectionName = section == 0 ? Constants.ChannelType.PublicTypeChannel : Constants.ChannelType.PrivateTypeChannel
        view.configureWithChannelType(Channel.privateTypeDisplayName(sectionName))
        view.addTapHandler = { print("ADD CHANNEL") }
        
        return view
    }

}

//MARK: - Navigation
extension LeftMenuViewController : Navigation {
    
    fileprivate func didSelectChannelAtIndexPath(_ indexPath: IndexPath) {
        let selectedChannel = (indexPath as NSIndexPath).section == 0 ? self.resultsPublic[indexPath.row] as Channel : self.resultsPrivate[indexPath.row] as Channel
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel
        self.tableView.reloadData()
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToMoreChannel(_ section: Int)  {
        let moreViewController = self.storyboard!.instantiateViewController(withIdentifier: "MoreChannelsViewController") as! MoreChannelsViewController
        moreViewController.isPrivateChannel = (section == 0) ? false : true
        (self.menuContainerViewController!.centerViewController as AnyObject).pushViewController(moreViewController, animated: true)
        toggleLeftSideMenu()
    }
    
    fileprivate func toggleLeftSideMenu() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    @IBAction func membersListAction(_ sender: AnyObject) {
        print("MEMBERS_LIST")
    }

}

