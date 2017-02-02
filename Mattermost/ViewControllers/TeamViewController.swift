//
//  TeamViewController.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 02.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class TeamViewController: UIViewController {
    
//MARK: Properties
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loaderView: UIView!
    
    var realm: Realm?
    fileprivate var results: Results<Team>! = nil
    fileprivate lazy var builder: TeamCellBuilder = TeamCellBuilder(tableView: self.tableView)
    var lastTeam: Team? = nil
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        prepareResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        replaceStatusBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
     //   UIStatusBar.shared().reset()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


fileprivate protocol Setup {
    func initialSetup()
    func setupTitleLabel()
    func setupTableView()
    func setupNavigationView()
}

fileprivate protocol Action {
    func backAction()
}

fileprivate protocol Navigation {
    func returnToPrevious()
}

fileprivate protocol Configuration {
    func prepareResults()
}

fileprivate protocol Request {
    func loadTeamChannels()
    func loadPreferedDirectChannelsInterlocuters()
    func loadTeamMembers()
}


//MARK: Setup
extension TeamViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupTitleLabel()
        setupTableView()
    }
    
    func setupNavigationBar() {
        let backButton = UIBarButtonItem.init(image: UIImage(named: "navbar_back_icon2"), style: .done, target: self, action: #selector(backAction))
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorStyle = .none
        self.tableView.register(TeamTableViewCell.classForCoder(), forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
    }
    
    func setupTitleLabel() {
        self.titleLabel.font = FontBucket.titleURLFont
        self.titleLabel.text = Preferences.sharedInstance.siteName
        self.titleLabel.textColor = ColorBucket.whiteColor
    }
    
    func setupNavigationView() {
        let bgLayer = CAGradientLayer.blueGradientForNavigationBar()
        bgLayer.frame = CGRect(x:0,y:0,width:self.navigationView.bounds.width,height: self.navigationView.bounds.height)
        bgLayer.animateLayerInfinitely(bgLayer)
        self.navigationView.layer.insertSublayer(bgLayer, at: 0)
        self.navigationView.bringSubview(toFront: self.titleLabel)
    }
}


//MARK: Action
extension TeamViewController: Action {
    func backAction() {
        returnToPrevious()
    }
}


//MARK: Navigation
extension TeamViewController: Navigation {
    func returnToPrevious() {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: Configuration
extension TeamViewController: Configuration {
    func prepareResults() {
        let sortName = TeamAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Team.self).sorted(byProperty: sortName, ascending: true)
    }
}


//MARK: Request
extension TeamViewController: Request {
    func loadTeamChannels() {
        Api.sharedInstance.loadChannels { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!);
                    self.refreshCurrentTeamIfNeeded()
                    DataManager.sharedInstance.currentTeam = self.lastTeam
                    Preferences.sharedInstance.currentTeamId = self.lastTeam!.identifier
                    Preferences.sharedInstance.save()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
                
                return }
            
            self.loadPreferedDirectChannelsInterlocuters()
        }
    }
    
    func loadPreferedDirectChannelsInterlocuters() {
        let preferences = Preference.preferedUsersList()
        var usersIds = Array<String>()
        preferences.forEach{ usersIds.append($0.name!) }
        
        Api.sharedInstance.loadUsersListBy(ids: usersIds) { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!);
                    self.refreshCurrentTeamIfNeeded()
                    DataManager.sharedInstance.currentTeam = self.lastTeam
                    Preferences.sharedInstance.currentTeamId = self.lastTeam!.identifier
                    Preferences.sharedInstance.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)

                return }
            self.loadTeamMembers()
        }
    }
    
    func loadTeamMembers() {
        let predicate = NSPredicate(format: "identifier != %@ AND identifier != %@", Preferences.sharedInstance.currentUserId!,
                                                                                     Constants.Realm.SystemUserIdentifier)
        let users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate)
        var ids = Array<String>()
        users.forEach{ ids.append($0.identifier) }
        
        Api.sharedInstance.loadTeamMembersListBy(ids: ids) { (error) in
            
            guard error == nil else { self.handleErrorWith(message: (error?.message)!);
                self.refreshCurrentTeamIfNeeded()
                DataManager.sharedInstance.currentTeam = self.lastTeam
                Preferences.sharedInstance.currentTeamId = self.lastTeam!.identifier
                Preferences.sharedInstance.save()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadLeftMenuNotification), object: nil)
                return }
            
            
            RouterUtils.loadInitialScreen()
          //  NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationsNames.ChatLoadingStopNotification), object: nil))
            
            DispatchQueue.main.async{
                self.dismiss(animated: true, completion:{ _ in
                    self.hideLoaderView()
                })
            }
        }
    }
}


//MARK: Support
extension TeamViewController {
    func refreshCurrentTeamIfNeeded() {
        if Preferences.sharedInstance.currentTeamId != nil { RealmUtils.refresh(withLogout: false) }
    }
}

//MARK: UITableViewDataSource
extension TeamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = self.results[indexPath.row]
        return self.builder.cellFor(team: team, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension TeamViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Api.sharedInstance.isNetworkReachable() else { handleErrorWith(message: "No Internet connectivity detected"); return }
        if (Preferences.sharedInstance.currentTeamId != nil) {
            lastTeam = DataManager.sharedInstance.currentTeam
        }
        let team = self.results[indexPath.row]
        if Preferences.sharedInstance.currentTeamId != team.identifier {
            refreshCurrentTeamIfNeeded()
            DataManager.sharedInstance.currentTeam = team
            Preferences.sharedInstance.currentTeamId = team.identifier
            Preferences.sharedInstance.save()
            showLoaderView()
            loadTeamChannels()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
