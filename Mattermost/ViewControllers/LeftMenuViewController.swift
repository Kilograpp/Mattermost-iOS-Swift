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
    
    fileprivate lazy var builder: LeftMenuCellBuilder = LeftMenuCellBuilder(tableView: self.tableView)
    
    var realm: Realm?
    fileprivate var resultsPublic: Results<Channel>! = nil
    fileprivate var resultsPrivate: Results<Channel>! = nil
    fileprivate var resultsDirect: Results<Channel>! = nil

//MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureResults()
        configureTableView()
        configureView()
        configureInitialSelectedChannel()
        configureStartUpdating()
    }
    
    func reloadMenu() {
        configureResults ()
        self.tableView.reloadData()
        configureInitialSelectedChannel()
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
        let publicTypePredicate = NSPredicate(format: "privateType == %@", Constants.ChannelType.PublicTypeChannel)
        let privateTypePredicate = NSPredicate(format: "privateType == %@", Constants.ChannelType.PrivateTypeChannel)
        let directTypePredicate = NSPredicate(format: "privateType == %@", Constants.ChannelType.DirectTypeChannel)
        
        let currentUserInChannelPredicate = NSPredicate(format: "currentUserInChannel == true")
        let sortName = ChannelAttributes.displayName.rawValue
        self.resultsPublic =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(publicTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsPrivate =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(privateTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsDirect =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(directTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
    }
    
}

//MARK: - UITableViewDataSource
extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return resultsPublic.count
        case 1:
            return resultsPrivate.count
        case 2:
            return resultsDirect.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var channel: Channel!
        switch indexPath.section {
        case 0:
            channel = self.resultsPublic[indexPath.row]
            break
        case 1:
            channel = self.resultsPrivate[indexPath.row]
            break
        case 2:
            channel = self.resultsDirect[indexPath.row]
            break
        default:
            break
        }
        
        return self.builder.cellFor(channel: channel, indexPath: indexPath)
    }
}

//MARK: - UITableViewDelegate
extension LeftMenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectChannelAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1) ? CGFloat(0.00001) : 30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard (section != 1) else { return nil }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionFooter.reuseIdentifier) as! LeftMenuSectionFooter
        view.moreTapHandler = { self.navigateToMoreChannel(section) }

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionHeader.reuseIdentifier) as! LeftMenuSectionHeader
        switch section {
        case 0:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.PublicTypeChannel))
            break
        case 1:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.PrivateTypeChannel))
            break
        case 2:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.DirectTypeChannel))
            break
        default:
            break
        }
        view.addTapHandler = { print("ADD CHANNEL") }
        
        return view
    }

}

//MARK: - Navigation
extension LeftMenuViewController : Navigation {
    fileprivate func didSelectChannelAtIndexPath(_ indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsPublic[indexPath.row]
        case 1:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsPrivate[indexPath.row]
        case 2:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsDirect[indexPath.row]
        default:
            print("unknown channel type")
        }
        
        self.tableView.reloadData()
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToMoreChannel(_ section: Int)  {
        let moreStoryboard = UIStoryboard(name:  "More", bundle: Bundle.main)
        let moreViewController = moreStoryboard.instantiateViewController(withIdentifier: "MoreChannelsViewController") as! MoreChannelsViewController
        moreViewController.isPrivateChannel = (section == 0) ? false : true
        (self.menuContainerViewController!.centerViewController as AnyObject).pushViewController(moreViewController, animated: true)
        toggleLeftSideMenu()
        
        
/*        let moreViewController = self.storyboard!.instantiateViewController(withIdentifier: "MoreChannelsViewController") as! MoreChannelsViewController
        moreViewController.isPrivateChannel = (section == 0) ? false : true
        (self.menuContainerViewController!.centerViewController as AnyObject).pushViewController(moreViewController, animated: true)
        toggleLeftSideMenu()*/
    }
    
    fileprivate func toggleLeftSideMenu() {
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    @IBAction func membersListAction(_ sender: AnyObject) {
        print("MEMBERS_LIST")
    }
}

