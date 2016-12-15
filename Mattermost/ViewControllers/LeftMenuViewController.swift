//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift

final class LeftMenuViewController: UIViewController {

//MARK: Property
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var membersListButton: UIButton!
    
    fileprivate lazy var builder: LeftMenuCellBuilder = LeftMenuCellBuilder(tableView: self.tableView)
    
    var realm: Realm?
    fileprivate var resultsPublic: Results<Channel>! = nil
    fileprivate var resultsPrivate: Results<Channel>! = nil
    fileprivate var resultsDirect: Results<Channel>! = nil
    fileprivate var resultsOutsideDirect: Results<Channel>! = nil
    
    //temp timer
    var statusesTimer: Timer?

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureResults()
        configureTableView()
        configureView()
        configureInitialSelectedChannel()
        setupChannelsObserver()
        configureStartUpdating()
        //reloadChannels()
    }
    
    //refactor later -> ObserverUtils
    func setupChannelsObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateResults),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadChannels),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopTimer),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.StatusesSocketNotification),
                                               object: nil)
    }
    
    //TEMP TODO:  update statuses
    fileprivate func configureStartUpdating() {
        //Костыль (для инициализации UserStatusObserver)
        UserStatusObserver.sharedObserver
        self.statusesTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateStatuses), userInfo: nil, repeats: true)
    }
    
    func updateStatuses() {
        SocketManager.sharedInstance.publishBackendNotificationFetchStatuses()
    }
    
    func stopTimer() {
        if (self.statusesTimer != nil) {
            self.statusesTimer?.invalidate()
            self.statusesTimer = nil
        }
    }
    
    func updateResults() {
        configureResults()
        configureInitialSelectedChannel()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadChannels()
    }
    
    func reloadChannels() {
        configureResults()
        self.tableView.reloadData()
    }
    
    func updateSelectionFor(_ channel: Channel) {
        let indexPath: IndexPath
        print(channel)
        switch channel.privateType! as String {
        case Constants.ChannelType.PublicTypeChannel:
            let row = self.resultsPublic.index(of: channel)
            indexPath = IndexPath(row: row!, section: 0)
        case Constants.ChannelType.PrivateTypeChannel:
            let row = self.resultsPrivate.index(of: channel)
            indexPath = IndexPath(row: row!, section: 1)
        case Constants.ChannelType.DirectTypeChannel:
            let row = channel.isDirectChannelInterlocutorInTeam ? self.resultsDirect.index(of: channel)
                                                                : self.resultsOutsideDirect.index(of: channel)
            let section = channel.isDirectChannelInterlocutorInTeam ? 2 : 3
            indexPath = IndexPath(row: row!, section: section)
        default:
            return
        }
        
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.tableView.reloadData()
    }
}

//MARK: PrivateProtocols
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
    func navigateToCreateChannel(privateType: String)
    func toggleLeftSideMenu()
    func membersListAction(_ sender: AnyObject)
}

//MARK: Configuration
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
    
    func configureInitialSelectedChannel() {
        let indexPathForFirstRow = IndexPath(row: 0, section: 0) as IndexPath
        guard self.resultsPublic.count > 0 else { return }
        let initialSelectedChannel = self.resultsPublic[indexPathForFirstRow.row]
        ChannelObserver.sharedObserver.selectedChannel = initialSelectedChannel
    }
    
    fileprivate func configureResults() {
        let publicTypePredicate = NSPredicate(format: "privateType == %@ AND team == %@", Constants.ChannelType.PublicTypeChannel, DataManager.sharedInstance.currentTeam!)
        let privateTypePredicate = NSPredicate(format: "privateType == %@ AND team == %@", Constants.ChannelType.PrivateTypeChannel, DataManager.sharedInstance.currentTeam!)
        let directTypePredicate = NSPredicate(format: "privateType == %@ AND team == %@ AND isDirectChannelInterlocutorInTeam == true", Constants.ChannelType.DirectTypeChannel, DataManager.sharedInstance.currentTeam!)
        let directOutsideTypePredicate = NSPredicate(format: "privateType == %@ AND team == %@ AND isDirectChannelInterlocutorInTeam == false AND messagesCount != %@", Constants.ChannelType.DirectTypeChannel, DataManager.sharedInstance.currentTeam!, "0")
        
        
        let currentUserInChannelPredicate = NSPredicate(format: "currentUserInChannel == true")
        let sortName = ChannelAttributes.displayName.rawValue
        self.resultsPublic =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(publicTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsPrivate =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(privateTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsDirect =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(directTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsOutsideDirect =
            RealmUtils.realmForCurrentThread().objects(Channel.self).filter(directOutsideTypePredicate).filter(currentUserInChannelPredicate).sorted(byProperty: sortName, ascending: true)
    }
}

//MARK: UITableViewDataSource
extension LeftMenuViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return resultsPublic.count
        case 1:
            return resultsPrivate.count
        case 2:
            return resultsDirect.count
        case 3:
            return resultsOutsideDirect.count
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
        case 3:
            channel = self.resultsOutsideDirect[indexPath.row]
        default:
            break
        }
        
        return self.builder.cellFor(channel: channel, indexPath: indexPath)
    }
}

//MARK: UITableViewDelegate
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
        return (section == 1) || (section == 3) ? CGFloat(0.00001) : 30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard (section != 1) && (section != 3) else { return nil }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionFooter.reuseIdentifier) as! LeftMenuSectionFooter
        view.moreTapHandler = { self.navigateToMoreChannel(section) }

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: LeftMenuSectionHeader.reuseIdentifier) as! LeftMenuSectionHeader
        switch section {
        case 0:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.PublicTypeChannel))
            view.addTapHandler = { self.navigateToCreateChannel(privateType: "O") }
            break
        case 1:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.PrivateTypeChannel))
            view.addTapHandler = { self.navigateToCreateChannel(privateType: "P") }
            break
        case 2:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.DirectTypeChannel))
            view.hideMoreButton()
            break
        case 3:
            view.configureWithChannelType(Channel.privateTypeDisplayName("out"))
            view.hideMoreButton()
        default:
            break
        }
        
        return view
    }

}

//MARK: Navigation
extension LeftMenuViewController : Navigation {
    fileprivate func didSelectChannelAtIndexPath(_ indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsPublic[indexPath.row]
        case 1:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsPrivate[indexPath.row]
        case 2:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsDirect[indexPath.row]
        case 3:
            ChannelObserver.sharedObserver.selectedChannel = self.resultsOutsideDirect[indexPath.row]
        default:
            print("unknown channel type")
        }
        self.tableView.reloadData()
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToMoreChannel(_ section: Int)  {
        let center = (self.menuContainerViewController!.centerViewController as AnyObject)
        guard !(center.topViewController??.isKind(of: MoreChannelsViewController.self))! else { return }
        
        let moreStoryboard = UIStoryboard(name:  "More", bundle: Bundle.main)
        let more = moreStoryboard.instantiateViewController(withIdentifier: "MoreChannelsViewController") as! MoreChannelsViewController
        more.isPrivateChannel = (section == 0) ? false : true
        center.pushViewController(more, animated: true)
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToCreateChannel(privateType: String) {
        
        let center = (self.menuContainerViewController!.centerViewController as AnyObject)
        guard !(center.topViewController??.isKind(of: CreateChannelViewController.self))! else { return }
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        ((center as! UINavigationController).viewControllers.last! as! ChatViewController).navigationItem.backBarButtonItem = backItem
        ((center as! UINavigationController).viewControllers.last! as! ChatViewController).navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navbar_back_icon")
        ((center as! UINavigationController).viewControllers.last! as! ChatViewController).navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navbar_back_icon")
        
        let moreStoryboard = UIStoryboard(name:  "More", bundle: Bundle.main)
        let createChannel = moreStoryboard.instantiateViewController(withIdentifier: "CreateChannelViewController") as! CreateChannelViewController
        createChannel.configure(privateType: privateType)
        center.pushViewController(createChannel, animated: true)
        toggleLeftSideMenu()
    }
    
    fileprivate func toggleLeftSideMenu() {
        let navigation = self.menuContainerViewController.centerViewController as! UINavigationController
        if navigation.viewControllers.count == 2 {
            let chat = navigation.viewControllers.first as! ChatViewController
            chat.postFromSearch = nil
        }
        
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    @IBAction func membersListAction(_ sender: AnyObject) {
        print("MEMBERS_LIST")
    }
    
    
}

