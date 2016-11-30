//
//  RightMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 15.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class RightMenuViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var builder: RightMenuCellBuilder = RightMenuCellBuilder(tableView: self.tableView)
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupTableView()
    func setupHeaderView()
    func toggleRightSideMenu()
    func setupNotificationsObserver()
}

fileprivate protocol Action {
    func headerTapAction()
}

fileprivate protocol Navigation {
    func proceedToProfile()
    func proceedToTeams()
    func proceedToFiles()
    func proceedToSettings()
    func proceedToInvite()
    func proceedToHelp()
    func proceedToReport()
    func proceedToAbout()
    func logOut()
}


//MARK: Setup
extension RightMenuViewController: Setup {
    func  initialSetup() {
        setupTableView()
        setupHeaderView()
        setupNotificationsObserver()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.isScrollEnabled = false
    }
    
    func setupHeaderView() {
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
        self.usernameLabel.font = FontBucket.rightMenuFont
        self.usernameLabel.textColor = ColorBucket.whiteColor
        
        let user = DataManager.sharedInstance.currentUser
        self.usernameLabel.text = user!.displayName
        
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        self.avatarImageView.layer.cornerRadius = 18
        self.avatarImageView.layer.masksToBounds = true
        ImageDownloader.downloadFeedAvatarForUser(user!) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }
        
        ImageDownloader.downloadFeedAvatarForUser(user!) { (image, error) in
            if (image != nil) {
                self.avatarImageView.image = image
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapAction))
        self.headerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func toggleRightSideMenu() {
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
    
    func setupNotificationsObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupHeaderView),
                                               name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadRightMenuNotification),
                                               object: nil)
    }
}


//MARK: Action
extension RightMenuViewController: Action {
    func headerTapAction() {
        toggleRightSideMenu()
        proceedToProfile()
    }
}


//MARK: Navigation
extension RightMenuViewController: Navigation {
    func proceedToProfile() {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureForCurrentUser(displayOnly: true)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
    }
    
    func proceedToTeams() {
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let teamViewController = storyboard.instantiateViewController(withIdentifier: "TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController)
        self.present(loginNavigationController, animated: true, completion: nil)
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
    
    func proceedToFiles() {
    
    }
    
    func proceedToSettings() {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureForCurrentUser(displayOnly: false)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
    }
    
    func proceedToInvite() {
        let storyboard = UIStoryboard.init(name: "RightMenu", bundle: nil)
        let about = storyboard.instantiateViewController(withIdentifier: "InviteNewMemberTableViewController")
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(about, animated:true)
    }
    
    func proceedToHelp() {
    
    }
    
    func proceedToReport() {
    
    }
    
    func proceedToAbout() {
        let storyboard = UIStoryboard.init(name: "RightMenu", bundle: nil)
        let about = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(about, animated:true)
    }
    
    
    func logOut() {
        UserStatusManager.sharedInstance.logout()
    }
}


//MARK: UITableViewDataSource
extension RightMenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension RightMenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.builder.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
        case Constants.RightMenuRows.SwitchTeam:
            proceedToTeams()
            
        case Constants.RightMenuRows.Files:
            print("Constants.RightMenuRows.Files")
            
         case Constants.RightMenuRows.Settings:
            toggleRightSideMenu()
            proceedToSettings()
         
        case Constants.RightMenuRows.InviteNewMembers:
            toggleRightSideMenu()
            proceedToInvite()
            
        case Constants.RightMenuRows.Help:
            print("Constants.RightMenuRows.Help")
            
        case Constants.RightMenuRows.Report:
            print("Constants.RightMenuRows.Report")
        
        case Constants.RightMenuRows.About:
            toggleRightSideMenu()
            proceedToAbout()
        
        case Constants.RightMenuRows.Logout:
            logOut()
         
        default:
            return
        }
    }
}
