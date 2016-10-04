//
//  RightMenuViewController.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 15.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

@objc private enum RightMenuRows : Int {
    case switchTeam
    case settings = 1
    case inviteNewMembers = 2
    case about = 3
    case logout = 4
}

class RightMenuViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//FIXME: вызов методов не должен быть через self
        self.configureTableView()
        self.configureHeaderVIew()
    }
}

private protocol PrivateConfig {
    func configureTableView()
    func configureHeaderVIew()
    func configureCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath)
}

extension RightMenuViewController : PrivateConfig {
    fileprivate func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
    }
    
    fileprivate func configureHeaderVIew() {
        self.headerView.backgroundColor = ColorBucket.sideMenuHeaderBackgroundColor
        self.usernameLabel.font = FontBucket.rightMenuFont
        self.usernameLabel.textColor = ColorBucket.whiteColor
        
        let user = DataManager.sharedInstance.currentUser
        self.usernameLabel.text = user!.displayName
        self.avatarImageView.sd_setImage(with: user!.avatarURL())
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapAction))
        self.headerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureCellAtIndexPath(_ cell: UITableViewCell, indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case RightMenuRows.switchTeam.rawValue:
            cell.textLabel?.text = "Switch team"
            cell.imageView?.image = UIImage(named: "menu_switch_icon")
            
        case RightMenuRows.settings.rawValue:
            cell.textLabel?.text = "Settings"
            cell.imageView?.image = UIImage(named: "menu_settings_icon")
            
        case RightMenuRows.inviteNewMembers.rawValue:
            cell.textLabel?.text = "Invite new members"
            cell.imageView?.image = UIImage(named: "menu_invite_icon")
            
        case RightMenuRows.about.rawValue:
            cell.textLabel?.text = "About Mattermost"
            cell.imageView?.image = UIImage(named: "menu_question_icon")
            
        case RightMenuRows.logout.rawValue:
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = UIImage(named: "menu_logout_icon")
            
        default:
            return
        }

    }
}


//MARK: - Private

extension RightMenuViewController {
    fileprivate func toggleRightSideMenu() {
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
}


//MARK: - Actions

extension RightMenuViewController {
    func headerTapAction() {
        toggleRightSideMenu()
        proceedToProfile()
    }
}


//MARK: - UITableViewDelegate

extension RightMenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case RightMenuRows.settings.rawValue:
            toggleRightSideMenu()
            proceedToSettings()
        case RightMenuRows.switchTeam.rawValue:
            proceedToTeams()
        case RightMenuRows.about.rawValue:
            toggleRightSideMenu()
            proceedToAbout()
        case RightMenuRows.logout.rawValue:
            logOut()
            
        default:
            return
        }
    }
}


//MARK: - UITableViewDataSource

extension RightMenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier:"Cell")
        }
        
        self.configureCellAtIndexPath(cell!, indexPath: indexPath)
        cell?.backgroundColor = ColorBucket.sideMenuBackgroundColor
        cell!.preservesSuperviewLayoutMargins = false;
        cell!.separatorInset = UIEdgeInsets.zero;
        cell!.layoutMargins = UIEdgeInsets.zero;
        cell?.selectionStyle = .default
        
        cell?.selectedBackgroundView = UIView(frame: cell!.bounds)
        cell?.selectedBackgroundView?.backgroundColor = ColorBucket.sideMenuCellHighlightedColor
        
        cell?.textLabel?.textColor = (indexPath as NSIndexPath).row == RightMenuRows.logout.rawValue ? ColorBucket.whiteColor : ColorBucket.rightMenuTextColor
        cell?.textLabel?.font = FontBucket.rightMenuFont
        
        return cell!
    }
}

//MARK: - Navigation
extension RightMenuViewController {
    func proceedToTeams() {
        let teamViewController = UIStoryboard(name:  "Login",
            bundle: Bundle.main).instantiateViewController(withIdentifier: "TeamViewController")
        let loginNavigationController = LoginNavigationController(rootViewController: teamViewController)
        self.present(loginNavigationController, animated: true, completion: nil)
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }
    
    func proceedToProfile() {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateInitialViewController()
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(profile!, animated:true)
    }
    
    func proceedToAbout() {
        // UNCOMMENT THIS
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let about = storyboard.instantiateViewControllerWithIdentifier(String(AboutViewController))
//        let navigation = self.menuContainerViewController.centerViewController
//        navigation!.pushViewController(about, animated:true)
        // DELETE THIS
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let about = storyboard.instantiateViewController(withIdentifier: String("MembersViewController"))
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(about, animated:true)
    }
    
    func proceedToSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let settings = storyboard.instantiateInitialViewController()
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(settings!, animated:true)
    }
    func logOut() {
        UserStatusManager.sharedInstance.logout()
    }
}
