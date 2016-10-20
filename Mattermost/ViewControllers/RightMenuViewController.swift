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
    
  
}


private protocol RightMenuViewControllerLifeCycle {
    func viewDidLoad()
}

private protocol RightMenuViewControllerSetup {
    func  initialSetup()
    func setupTableView()
    func setupHeaderView()
}

private protocol RightMenuViewControllerAction {
    func headerTapAction()
}

private protocol RightMenuViewControllerNavigation {
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

private protocol RightMenuViewControllerPrivate {
    func toggleRightSideMenu()
}


//MARK: RightMenuViewControllerLifeCycle

extension RightMenuViewController: RightMenuViewControllerLifeCycle {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
}


//MARK: RightMenuViewControllerSetup

extension RightMenuViewController: RightMenuViewControllerSetup {
    func  initialSetup() {
        setupTableView()
        setupHeaderView()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapAction))
        self.headerView.addGestureRecognizer(tapGestureRecognizer)
    }
}


//MARK: RightMenuViewControllerAction

extension RightMenuViewController: RightMenuViewControllerAction {
    func headerTapAction() {
        toggleRightSideMenu()
        proceedToProfile()
    }
}


//MARK: RightMenuViewControllerNavigation

extension RightMenuViewController: RightMenuViewControllerNavigation {
    func proceedToProfile() {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        (profile as! ProfileViewController).configureForCurrentUser()
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
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settings = storyboard.instantiateInitialViewController()
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(settings!, animated:true)
    }
    
    func proceedToInvite() {
    
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


//MARK: RightMenuViewControllerPrivate

extension RightMenuViewController: RightMenuViewControllerPrivate {
    func toggleRightSideMenu() {
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
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
        switch (indexPath as NSIndexPath).row {
        case Constants.RightMenuRows.SwitchTeam:
            proceedToTeams()
            
        case Constants.RightMenuRows.Files:
            print("Constants.RightMenuRows.Files")
            
         case Constants.RightMenuRows.Settings:
            toggleRightSideMenu()
            proceedToSettings()
         
        case Constants.RightMenuRows.InviteNewMembers:
            print("Constants.RightMenuRows.InviteNewMembers")
            
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
