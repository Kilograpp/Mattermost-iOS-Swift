//
//  LeftMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import RealmSwift


private protocol Interface: class {
    func setupChannelsObserver()
    func updateStatuses()
    func stopTimer()
    func reloadChannels()
}


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
    
    var statusesTimer: Timer?

//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: Interface
extension LeftMenuViewController: Interface {
    //refactor later -> ObserverUtils
    func setupChannelsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateResults),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.UserJoinNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChannels),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.StatusesSocketNotification),
                                               object: nil)
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
    
    func reloadChannels() {
        prepareResults()
        self.tableView.reloadData()
    }
    
    func updateSelectionFor(_ channel: Channel) {
        let indexPath: IndexPath
//        print(channel)
        switch channel.privateType! as String {
        case Constants.ChannelType.PublicTypeChannel:
            let row = self.resultsPublic.index(of: channel)
            indexPath = IndexPath(row: row!, section: 0)
        case Constants.ChannelType.PrivateTypeChannel:
            let row = self.resultsPrivate.index(of: channel)
            indexPath = IndexPath(row: row!, section: 1)
        case Constants.ChannelType.DirectTypeChannel:
            let user = channel.interlocuterFromPrivateChannel()
            let section = user.isOnTeam ? 2 : 3
            let row = user.isOnTeam ? self.resultsDirect.index(of: channel)
                                        : self.resultsOutsideDirect.index(of: channel)
            indexPath = IndexPath(row: row!, section: section)
        default:
            return
        }
        
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        self.tableView.reloadData()
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupTableView()
    func setupHeaderView()
    func setupStartUpdating()
}

fileprivate protocol Configuration: class {
    func prepareResults()
    func configureInitialSelectedChannel()
    func updateResults()
}

private protocol Navigation : class {
    func didSelectChannelAtIndexPath(_ indexPath: IndexPath)
    func navigateToMoreChannel(_ section: Int)
    func navigateToCreateChannel(privateType: String)
    func toggleLeftSideMenu()
}


//MARK: Setup
extension LeftMenuViewController: Setup {
    func initialSetup() {
        prepareResults()
        setupTableView()
        setupHeaderView()
        configureInitialSelectedChannel()
        setupChannelsObserver()
        setupStartUpdating()
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        
        self.tableView.register(LeftMenuSectionHeader.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionHeader.reuseIdentifier)
        self.tableView.register(LeftMenuSectionFooter.self, forHeaderFooterViewReuseIdentifier: LeftMenuSectionFooter.reuseIdentifier)
    }
    
    func setupHeaderView() {
        self.teamNameLabel.font = FontBucket.menuTitleFont
        self.teamNameLabel.textColor = ColorBucket.whiteColor
        self.teamNameLabel.text = DataManager.sharedInstance.currentTeam?.displayName as String!
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
    }
    
    func setupStartUpdating() {
        //Костыль (для инициализации UserStatusObserver)
        _ = UserStatusObserver.sharedObserver
        self.statusesTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateStatuses), userInfo: nil, repeats: true)
    }
}


//MARK: Configuration
extension LeftMenuViewController: Configuration {
    fileprivate func prepareResults() {
        guard (DataManager.sharedInstance.currentTeam != nil) else { return }
        let currentTeamPredicate          = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let currentUserInChannelPredicate = NSPredicate(format: "currentUserInChannel == true")
        let publicTypePredicate           = NSPredicate(format: "privateType == %@", Constants.ChannelType.PublicTypeChannel)
        let privateTypePredicate          = NSPredicate(format: "privateType == %@", Constants.ChannelType.PrivateTypeChannel)
        let directTypePredicate           = NSPredicate(format: "privateType == %@", Constants.ChannelType.DirectTypeChannel)
        let directPreferedPredicate       = NSPredicate(format: "isDirectPrefered == true")
        let sortName                      = ChannelAttributes.displayName.rawValue
        
        let realm = RealmUtils.realmForCurrentThread()
        self.resultsPublic =
            realm.objects(Channel.self).filter(currentTeamPredicate).filter(currentUserInChannelPredicate).filter(publicTypePredicate).sorted(byProperty: sortName, ascending: true)
        self.resultsPrivate =
            realm.objects(Channel.self).filter(currentTeamPredicate).filter(currentUserInChannelPredicate).filter(privateTypePredicate).sorted(byProperty: sortName, ascending: true)
        
        let allDirect = realm.objects(Channel.self).filter(currentTeamPredicate).filter(currentUserInChannelPredicate).filter(directTypePredicate).filter(directPreferedPredicate)
        
        self.resultsDirect = allDirect.filter(NSPredicate(format: "isInterlocuterOnTeam == true")).sorted(byProperty: sortName, ascending: true)
        self.resultsOutsideDirect = allDirect.filter(NSPredicate(format: "isInterlocuterOnTeam == false")).sorted(byProperty: sortName, ascending: true)
    }
    
    func configureInitialSelectedChannel() {
        guard self.resultsPublic.count > 0 else { return }
        ChannelObserver.sharedObserver.selectedChannel = self.resultsPublic[0]
    }
    
    func updateResults() {
        prepareResults()
        configureInitialSelectedChannel()
        self.tableView.reloadData()
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
        default: break
//            print("unknown channel type")
        }
        self.tableView.reloadData()
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToMoreChannel(_ section: Int)  {
        
        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            return
        }
        
        let center = (self.menuContainerViewController!.centerViewController as AnyObject)
        guard !(center.topViewController??.isKind(of: MoreChannelsViewController.self))! else { return }
        
        let moreStoryboard = UIStoryboard(name:  "More", bundle: Bundle.main)
        let more = moreStoryboard.instantiateViewController(withIdentifier: "MoreChannelsViewController") as! MoreChannelsViewController
        more.isPrivateChannel = (section == 0) ? false : true
        center.pushViewController(more, animated: true)
        toggleLeftSideMenu()
    }
    
    fileprivate func navigateToCreateChannel(privateType: String) {
        
        let currentTeamPredicate = NSPredicate(format: "team == %@", DataManager.sharedInstance.currentTeam!)
        let realm = RealmUtils.realmForCurrentThread()
        guard realm.objects(Channel.self).filter(currentTeamPredicate).count > 0 else {
            self.handleErrorWith(message: "Error when choosing team.\nPlease rechoose team")
            return
        }
        
        let center = (self.menuContainerViewController!.centerViewController as AnyObject)
        guard !(center.topViewController??.isKind(of: CreateChannelViewController.self))! else { return }
        
        let moreStoryboard = UIStoryboard(name:  "More", bundle: Bundle.main)
        let createChannel = moreStoryboard.instantiateViewController(withIdentifier: "CreateChannelViewController") as! CreateChannelViewController
        createChannel.configure(privateType: privateType)
        center.pushViewController(createChannel, animated: true)
        toggleLeftSideMenu()
    }
    
    fileprivate func toggleLeftSideMenu() {
        let navigation = self.menuContainerViewController.centerViewController as! UINavigationController
        if navigation.viewControllers.count == 2 {
            _ = navigation.viewControllers.first as! ChatViewController
        //    chat.postFromSearch = nil
        }
        
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
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
            return (resultsPublic != nil) ? resultsPublic.count : 0
        case 1:
            return (resultsPrivate != nil) ? resultsPrivate.count : 0
        case 2:
            return (resultsDirect != nil) ? resultsDirect.count : 0
        case 3:
            return (resultsOutsideDirect != nil) ? resultsOutsideDirect.count : 0
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
            view.hideMoreButton()
            break
        case 1:
            view.configureWithChannelType(Channel.privateTypeDisplayName(Constants.ChannelType.PrivateTypeChannel))
            view.addTapHandler = { self.navigateToCreateChannel(privateType: "P") }
            view.hideMoreButton()
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
